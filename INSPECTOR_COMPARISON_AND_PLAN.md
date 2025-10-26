# Inspector Feature: Android vs iOS - Comparison & Implementation Plan

## 📊 Current State Analysis

### ✅ What iOS Inspector Already Has (Can Reuse)

| Component | Status | Notes |
|-----------|--------|-------|
| **Domain Models** | ✅ Excellent | `NetworkTransaction`, `NetworkRequest`, `NetworkResponse` - well structured |
| **HTTP Method Enum** | ✅ Complete | All methods covered (GET, POST, PUT, DELETE, PATCH, HEAD, OPTIONS, TRACE, CONNECT) |
| **Transaction Status** | ✅ Good | pending, completed, failed, cancelled |
| **Status Categories** | ✅ Good | 1xx, 2xx, 3xx, 4xx, 5xx categorization |
| **URL Interception** | ✅ Working | Uses `URLProtocol` pattern |
| **Repository Protocol** | ✅ Well designed | Clean interface for CRUD operations |
| **Use Cases** | ✅ Good | MonitorNetworkTransactionsUseCase, GetNetworkTransactionUseCase, FilterNetworkTransactionsUseCase |
| **Presentation Layer** | ✅ Clean architecture | UIState pattern, proper ViewModel structure |

---

### ⚠️ What iOS Inspector is Missing (vs Android)

| Feature | Android | iOS | Gap |
|---------|---------|-----|-----|
| **Persistent Storage** | ✅ Room SQLite | ❌ In-memory only | ❌ **CRITICAL** - Data lost on app restart |
| **Header Redaction** | ✅ Auto-redacts sensitive headers | ❌ None | ⚠️ **Security issue** |
| **Body Size Limits** | ✅ 250KB max | ❌ Unlimited | ⚠️ **Memory issue** |
| **Request/Response Timing** | ✅ Accurate duration tracking | ⚠️ Basic | ⚠️ **Needs improvement** |
| **Pagination** | ✅ Smart pagination (20/50 per page) | ❌ None | ⚠️ **Performance issue** |
| **Search Functionality** | ✅ Full-text search | ❌ None in UI | ⚠️ **UX issue** |
| **Method Filtering** | ✅ Yes | ⚠️ Partial | ⚠️ **Needs UI** |
| **Status Filtering** | ✅ Yes | ⚠️ Partial | ⚠️ **Needs UI** |
| **Date Grouping** | ✅ Yes (Today, Yesterday, etc.) | ❌ None | ⚠️ **UX issue** |
| **Clear All** | ✅ Yes with confirmation | ❌ None | ⚠️ **UX issue** |
| **Pull-to-Refresh** | ✅ Yes | ❌ None | ⚠️ **UX issue** |

---

## 🎯 Implementation Strategy

### Phase 1: Critical Fixes (Highest Priority)

#### 1.1 Add Persistent Storage (CoreData or SQLite)

**Problem:** iOS uses in-memory storage - data lost on app restart
**Solution:** Use CoreData (Apple's equivalent of Room)

**Implementation:**

```swift
// Create CoreData model
@Model
class NetworkTransactionEntity {
    @Attribute(.unique) var id: String
    var url: String
    var method: String
    var requestHeaders: String  // JSON
    var requestBody: Data?
    var responseHeaders: String?  // JSON
    var responseBody: Data?
    var statusCode: Int?
    var startTime: Date
    var endTime: Date?
    var status: String
    var requestTimestamp: Date
    var responseTimestamp: Date?
}
```

**Files to modify:**
- Create: `NetworkTransactionEntity.swift` (Data layer)
- Modify: `NetworkTransactionRepository.swift` - Replace in-memory array with CoreData queries
- Add: SwiftData/CoreData stack initialization

---

#### 1.2 Add Header Redaction (Security)

**Problem:** Sensitive headers (Authorization, Cookie, API keys) exposed
**Solution:** Auto-redact like Android

**Implementation:**

```swift
// Add to NetworkRequest/NetworkResponse
private let redactedHeaders = Set([
    "authorization",
    "cookie",
    "set-cookie",
    "x-api-key",
    "x-auth-token",
    "authentication"
])

func redactHeaders(_ headers: [String: String]) -> [String: String] {
    return headers.mapValues { (key, value) in
        redactedHeaders.contains(key.lowercased()) ? "██████" : value
    }
}
```

**Files to modify:**
- `NetworkInterceptor.swift` - Redact before saving
- `NetworkRequest.swift` / `NetworkResponse.swift` - Add redaction logic

---

#### 1.3 Add Body Size Limits (Memory Safety)

**Problem:** Large responses can crash the app
**Solution:** Limit to 250KB like Android

**Implementation:**

```swift
private let MAX_BODY_SIZE = 250_000  // bytes

func truncateBody(_ data: Data?) -> Data? {
    guard let data = data else { return nil }

    if data.count > MAX_BODY_SIZE {
        // Store truncation indicator
        return "[Content too large: \(data.count) bytes]".data(using: .utf8)
    }

    return data
}
```

**Files to modify:**
- `NetworkInterceptor.swift` - Truncate before saving

---

### Phase 2: Timing & Accuracy Improvements

#### 2.1 Accurate Duration Tracking

**Problem:** iOS doesn't track timing precisely
**Solution:** Use `Date().timeIntervalSince1970` like Android

**Implementation:**

```swift
// In NetworkInterceptor
private var requestStartTimes: [String: TimeInterval] = [:]

func handleRequestStarted(_ request: URLRequest) {
    let requestId = UUID().uuidString
    requestStartTimes[requestId] = Date().timeIntervalSince1970
    // ... rest of logic
}

func handleRequestCompleted(...) {
    let endTime = Date().timeIntervalSince1970
    let startTime = requestStartTimes[requestId] ?? endTime
    let duration = endTime - startTime
    // Create NetworkResponse with accurate responseTime
}
```

**Files to modify:**
- `NetworkInterceptor.swift` - Track timing precisely

---

### Phase 3: UI/UX Enhancements

#### 3.1 Add Search Functionality

**Implementation:**

```swift
// In PreferencesUIState
var searchQuery: String = ""

// In ViewModel
func search(_ query: String) {
    uiState.searchQuery = query
    // Filter transactions by URL, method, or status code
}
```

**Files to modify:**
- `NetworkInspectorUIState.swift` - Add searchQuery
- `NetworkInspectorViewModel.swift` - Add search logic
- `NetworkInspectorView.swift` - Add DSSearchField

---

#### 3.2 Add Pagination

**Implementation:**

```swift
// In NetworkInspectorViewModel
private var currentPage = 0
private let pageSize = 20

func loadMore() {
    currentPage += 1
    let offset = currentPage * pageSize
    // Load next page from repository
}
```

**Files to modify:**
- `NetworkInspectorViewModel.swift` - Add pagination logic
- `NetworkTransactionRepository.swift` - Add fetchPaged(offset:limit:)

---

#### 3.3 Add Method/Status Filters

**Implementation:**

```swift
// In NetworkInspectorView
DSSegmentedControl(
    selectedSegment: .constant(viewModel.uiState.selectedMethod),
    segments: HTTPMethod.allCases.map { method in
        DSSegmentedControl.Segment(id: method.rawValue, title: method.displayName)
    }
)
```

**Files to modify:**
- `NetworkInspectorUIState.swift` - Add selectedMethod, selectedStatus
- `NetworkInspectorViewModel.swift` - Add filter logic
- `NetworkInspectorView.swift` - Add filter chips

---

#### 3.4 Add Date Grouping

**Implementation:**

```swift
func groupByDate(_ transactions: [NetworkTransaction]) -> [DateGroup] {
    let grouped = Dictionary(grouping: transactions) { transaction in
        Calendar.current.startOfDay(for: transaction.startTime)
    }

    return grouped.map { date, transactions in
        DateGroup(
            title: formatDateGroup(date),
            transactions: transactions.sorted { $0.startTime > $1.startTime }
        )
    }.sorted { $0.date > $1.date }
}

func formatDateGroup(_ date: Date) -> String {
    if Calendar.current.isDateInToday(date) {
        return "Today"
    } else if Calendar.current.isDateInYesterday(date) {
        return "Yesterday"
    } else {
        return date.formatted(date: .abbreviated, time: .omitted)
    }
}
```

**Files to modify:**
- `NetworkInspectorViewModel.swift` - Add grouping logic
- `NetworkInspectorView.swift` - Render grouped sections

---

#### 3.5 Add Clear All / Pull-to-Refresh

**Implementation:**

```swift
// Clear All
.toolbar {
    ToolbarItem(placement: .navigationBarTrailing) {
        Menu {
            Button("Clear All", role: .destructive) {
                showClearConfirmation = true
            }
        } label: {
            Image(systemName: "ellipsis.circle")
        }
    }
}
.confirmationDialog("Clear All?", isPresented: $showClearConfirmation) {
    Button("Clear All", role: .destructive) {
        viewModel.clearAll()
    }
}

// Pull-to-Refresh
.refreshable {
    await viewModel.loadTransactions()
}
```

**Files to modify:**
- `NetworkInspectorView.swift` - Add toolbar menu and refreshable

---

## 🏗️ Recommended Architecture (Matching Android)

```
NetworkInterceptor (URLProtocol)
    ↓
    ├─ Redact sensitive headers
    ├─ Truncate large bodies (>250KB)
    ├─ Track accurate timing
    ↓
NetworkTransactionCollector (Async)
    ↓
NetworkTransactionRepository
    ↓
CoreData / SQLite (Persistent Storage)
    ↓
Use Cases (Get, Filter, Monitor)
    ↓
ViewModel (with UIState, Pagination, Filtering)
    ↓
View (SwiftUI with Search, Filters, Groups, Refresh)
```

---

## 📋 Implementation Checklist

### Critical (Must Have)
- [ ] Replace in-memory storage with CoreData/SQLite
- [ ] Add header redaction for security
- [ ] Add body size limits (250KB max)
- [ ] Fix duration tracking accuracy

### High Priority (Should Have)
- [ ] Add search functionality
- [ ] Add pagination (20/50 per page)
- [ ] Add method filter chips
- [ ] Add status filter chips
- [ ] Add pull-to-refresh

### Medium Priority (Nice to Have)
- [ ] Add date grouping (Today, Yesterday, etc.)
- [ ] Add clear all with confirmation
- [ ] Add transaction details screen
- [ ] Add copy/share functionality

### Low Priority (Future)
- [ ] Add export to file (JSON, HAR format)
- [ ] Add request/response editing (MOCK mode)
- [ ] Add request replay functionality

---

## 🎯 Final Goal: Parity with Android

**Android Inspector Features:**
1. ✅ Persistent storage (Room SQLite)
2. ✅ Header redaction (security)
3. ✅ Body size limits (250KB)
4. ✅ Accurate timing
5. ✅ Search functionality
6. ✅ Pagination (20/50 per page)
7. ✅ Method filtering
8. ✅ Status filtering
9. ✅ Date grouping
10. ✅ Pull-to-refresh
11. ✅ Clear all with confirmation

**iOS Inspector Status:**
- ✅ Basic interception working
- ⚠️ Missing persistence, security, and UX features
- 🎯 Goal: Match Android feature parity

---

## 📝 Notes

- **Simplest Setup:** iOS already has simple setup with `URLProtocol.registerClass()` - similar to Android's OkHttp interceptor pattern
- **Reuse Existing Code:** Most domain models and architecture are excellent - just need to fill gaps
- **Focus on Storage First:** Persistent storage is critical - everything else builds on top of it
