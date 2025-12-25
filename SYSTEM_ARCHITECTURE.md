# Food Delivery App - Architecture & Commission System

## 📊 Complete System Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                     FIREBASE BACKEND                            │
│  ┌──────────────────┬─────────────────┬───────────────────┐    │
│  │  Firestore DB    │  Authentication │  Cloud Storage    │    │
│  │                  │                 │                   │    │
│  │ ├─ orders        │ ├─ Admin        │ ├─ Profiles       │    │
│  │ ├─ sellers       │ ├─ Users        │ ├─ Menus          │    │
│  │ ├─ users         │ ├─ Sellers      │ └─ Orders         │    │
│  │ └─ riders        │ └─ Riders       │                   │    │
│  └──────────────────┴─────────────────┴───────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
           ▲                    ▲                    ▲
           │                    │                    │
    ┌──────┴─────────┐   ┌──────┴──────┐    ┌──────┴─────┐
    │                │   │             │    │            │
    ▼                ▼   ▼             ▼    ▼            ▼
┌─────────────┐ ┌──────────┐ ┌───────────┐ ┌──────────┐ ┌──────┐
│ User App    │ │ Seller   │ │ Admin     │ │ Rider    │ │ Web  │
│ (rider)     │ │ App      │ │ Portal    │ │ App      │ │Portal│
│             │ │          │ │           │ │          │ │(Fut.)│
│ • Home      │ │ • Orders │ │ • Orders  │ │ • Tasks  │ │      │
│ • Cart      │ │ • Menu   │ │ • Sellers │ │ • Track  │ │      │
│ • Checkout  │ │ • Earnings│ │ • Commission
│ • Orders    │ │ • Profile│ │ • Stats   │ │ • Earnings
└─────────────┘ └──────────┘ └───────────┘ └──────────┘ └──────┘
```

## 💰 Commission Flow System

```
USER PLACES ORDER
        │
        ▼
   Order Created
   Total: ₹500
        │
        ├─────────────────┬──────────────────┐
        │                 │                  │
        ▼                 ▼                  ▼
   System calculates  Save to global    Save to user
   commission:        'orders'          order history
        │             collection        (backup)
        ├─ 10% Company
        ├─ 90% Seller    │
        │                ▼
        │         Firestore Document
        │         {
        │           orderId: "123"
        │           totalAmount: 500
        │           companyCommission: 50 (10%)
        │           sellerAmount: 450 (90%)
        │           paymentMethod: "card"
        │           ...
        │         }
        │
        └──► Update Seller Stats
             ├─ totalOrders: +1
             └─ totalEarnings: +450
                (90% of order)
                
        Order Status Flow:
        pending → confirmed → preparing → ready 
        → in_delivery → ended/cancelled
        
        Each status change synced to:
        • Global orders collection (Admin sees)
        • Seller's order list
        • User's order history
        • Rider app (if assigned)
```

## 🗂️ Data Flow Between Apps

```
┌─────────────┐
│  USER APP   │
└─────────────┘
       │
       │ Creates Order
       │ (with commission fields)
       │
       ▼
    FIRESTORE
    ├─ orders/{orderId}
    └─ users/{userId}/orders/{orderId}
       │
       ├───────────────────┬──────────────┬─────────────────┐
       │                   │              │                 │
       ▼                   ▼              ▼                 ▼
   [SELLER APP]      [ADMIN PORTAL]  [RIDER APP]    [SELLER UPDATES]
       │                   │              │                 │
   Updates Status    Monitors          Accepts          Updates Stats
   • preparing       • Commission      • Assigns        • Earnings
   • ready           • Orders          • Tracks         • Orders
       │             • Sellers         • Delivers       │
       │             • Stats           │                │
       └────────────────┴──────────────┴────────────────┘
                        │
                        ▼
                Order Status Synced
                Across All Apps
```

## 📱 Admin Portal Structure

```
ADMIN PORTAL
    │
    ├─ 📊 DASHBOARD
    │   ├─ Total Orders (Stat)
    │   ├─ Total Commission (Stat)
    │   ├─ Active Sellers (Stat)
    │   ├─ Pending Orders (Stat)
    │   └─ Quick Actions
    │
    ├─ 🛒 ORDERS MANAGEMENT
    │   ├─ Filter by Status
    │   │   ├─ Pending
    │   │   ├─ Confirmed
    │   │   ├─ Preparing
    │   │   ├─ Ready
    │   │   ├─ In Delivery
    │   │   ├─ Delivered
    │   │   └─ Cancelled
    │   │
    │   ├─ Order Card Shows
    │   │   ├─ Order ID
    │   │   ├─ Seller Name
    │   │   ├─ Total Amount
    │   │   ├─ Company Commission (10%)
    │   │   ├─ Seller Amount (90%)
    │   │   ├─ Payment Method
    │   │   ├─ Rider Assigned
    │   │   └─ Order Time
    │   │
    │   └─ Actions
    │       ├─ View Details
    │       └─ Update Status
    │
    ├─ 🏪 SELLERS MANAGEMENT
    │   ├─ Filter by Status
    │   │   ├─ All Sellers
    │   │   ├─ Approved
    │   │   └─ Pending
    │   │
    │   ├─ Seller Card Shows
    │   │   ├─ Name
    │   │   ├─ Email
    │   │   ├─ Total Orders
    │   │   ├─ Total Earnings
    │   │   ├─ Rating
    │   │   ├─ Approval Status
    │   │   └─ Contact Info
    │   │
    │   └─ Actions
    │       ├─ View Details
    │       ├─ Approve (if pending)
    │       └─ Remove (if approved)
    │
    └─ 💳 COMMISSION TRACKING
        ├─ Statistics
        │   ├─ Total Commission
        │   ├─ Card Payment Commission
        │   └─ COD Commission
        │
        ├─ Filter by Payment Method
        │   ├─ All Orders
        │   ├─ Card Payments
        │   └─ Cash on Delivery
        │
        └─ Transaction Records
            ├─ Order ID
            ├─ Seller Name
            ├─ Amount Breakdown
            │   ├─ Total Order
            │   ├─ Company Gets (10%)
            │   └─ Seller Gets (90%)
            ├─ Payment Method
            └─ Order Time
```

## 🔄 Order Status Lifecycle

```
┌─────────────────────────────────────────────────────────────────┐
│                    ORDER LIFECYCLE                              │
└─────────────────────────────────────────────────────────────────┘

START
  │
  ▼
[PENDING] ─── User placed order
              Commission calculated & saved
              Admin sees it in dashboard
  │
  ▼
[CONFIRMED] ─ Seller accepted order
              Order moved to "preparing"
              Admin updates if needed
  │
  ▼
[PREPARING] ─ Seller is making the food
              Admin can monitor
  │
  ▼
[READY] ───── Food is ready
              Ready for rider pickup
              Rider can see it in app
  │
  ▼
[IN_DELIVERY] ─ Rider assigned & delivering
               Cash collected (if COD)
               Tracking available
  │
  ├─ SUCCESS
  │   ▼
  │ [ENDED] ─── Order delivered successfully
  │             Payment processed
  │             Commission finalized
  │             Admin report updated
  │
  └─ FAILURE
      ▼
    [CANCELLED] ─ Order cancelled
                 Refund processed (if applicable)
                 Commission not counted
```

## 💰 Commission Calculation Example

```
ORDER DETAILS
─────────────
Customer Orders:
  • Biryani: ₹250 x 1
  • Naan: ₹50 x 2
  • Drinks: ₹50 x 1
  • Delivery Fee: ₹30
  ─────────────────────
  TOTAL: ₹500

COMMISSION SPLIT
────────────────
  Total Amount: ₹500
       │
       ├─► Company Gets (10%)
       │   └─ 500 × 0.10 = ₹50
       │
       └─► Seller Gets (90%)
           └─ 500 × 0.90 = ₹450

FIRESTORE RECORD
────────────────
{
  "orderId": "1703414400000",
  "totalAmount": 500,
  "companyCommission": 50,          // 10%
  "sellerAmount": 450,               // 90%
  "paymentMethod": "cash_on_delivery",
  "status": "pending",
  "sellerId": "seller123",
  "sellerName": "Biryani House",
  "userId": "user456",
  "orderTime": "1703414400000",
  "items": [
    {
      "itemName": "Biryani",
      "quantity": "1",
      "price": "250"
    },
    ...
  ]
}

SELLER STATS UPDATE
───────────────────
sellers/seller123
├─ totalOrders: +1     (now 25)
└─ totalEarnings: +450 (now 10,350)
   (90% commission added)
```

## 🔒 Security Flow

```
ADMIN LOGIN
    │
    ├─ Enter Credentials
    │   ├─ Email
    │   └─ Password
    │
    ▼
FIREBASE AUTHENTICATION
    │
    ├─ Verify Credentials
    │   ├─ Check Email exists
    │   └─ Check Password matches
    │
    ▼
CREATE SESSION
    │
    ├─ Store Auth Token
    ├─ Initialize Firebase Connection
    └─ Load Dashboard
    
ACCESS CONTROL
    │
    ├─ Admin Only
    │   ├─ Can Read All Orders
    │   ├─ Can Update Orders
    │   ├─ Can Manage Sellers
    │   └─ Can View Reports
    │
    └─ Seller/User/Rider
        ├─ Can Only Read Own Data
        └─ Limited Write Access

LOGOUT
    │
    ├─ Destroy Session
    ├─ Clear Local Data
    └─ Return to Login Screen
```

## 📊 Real-time Data Sync

```
DATABASE CHANGE
    │
    ▼
FIRESTORE TRIGGERS UPDATE
    │
    ├──────────────┬──────────────┬──────────────┐
    │              │              │              │
    ▼              ▼              ▼              ▼
[ADMIN SEES]  [SELLER SEES]  [USER SEES]  [RIDER SEES]
    │              │              │              │
 Dashboard      Orders List   Order Status   Available
 Updates        Updates       Updates        Orders
    │              │              │              │
    └──────────────┴──────────────┴──────────────┘
                    │
                    ▼
            STREAM BUILDER
            TRIGGERS UI REFRESH
                    │
                    ▼
            REAL-TIME UPDATE
            (No Manual Refresh)
```

## 🎯 Payment Method Tracking

```
PAYMENT METHOD SELECTION
    │
    ├─ CARD PAYMENT
    │   │
    │   ├─ Process through Razorpay
    │   ├─ Store: paymentMethod = "card"
    │   ├─ Mark: cashCollected = false
    │   └─ Commission counted immediately
    │
    └─ CASH ON DELIVERY (COD)
        │
        ├─ Store: paymentMethod = "cash_on_delivery"
        ├─ Rider collects cash at delivery
        ├─ Mark: cashCollected = true (when delivered)
        ├─ Track in COD-specific reports
        └─ Commission counted at delivery completion
```

## 📈 Admin Analytics

```
ADMIN PORTAL REPORTS
    │
    ├─ OVERALL STATS
    │   ├─ Total Orders: X
    │   ├─ Total Revenue: ₹Y
    │   ├─ Total Commission: ₹(Y × 0.10)
    │   └─ Average Order Value: ₹(Y/X)
    │
    ├─ SELLER METRICS
    │   ├─ Top Sellers (by earnings)
    │   ├─ Active Sellers
    │   ├─ New Sellers (pending approval)
    │   └─ Seller Ratings
    │
    ├─ PAYMENT ANALYSIS
    │   ├─ Card Payments: X% of orders
    │   ├─ COD Orders: Y% of orders
    │   └─ Commission by Payment Type
    │
    └─ ORDER ANALYSIS
        ├─ Completed Orders: X
        ├─ Pending Orders: Y
        ├─ Cancelled Orders: Z
        ├─ Average Delivery Time
        └─ Peak Order Times
```

---

**Last Updated**: December 2024  
**Version**: 1.0.0
