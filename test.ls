
WayForPay = require('./wayforpay.js')
wayforpay = new WayForPay('test_merch_n1', 'flk3409refn54t54t*FNJRET')
p = 
  'merchantDomainName': 'app.wepster.com'
  'merchantTransactionSecureType': 'AUTO'
  'serviceUrl': 'http://yourdomain.com/wfp/return'
  'orderReference': 'orderid001'
  'orderDate': '14898322'
  'amount': '1.00'
  'currency': 'USD'
  'productName': 'product name'
  'productPrice': '2.00'
  'productCount': '2'
  'language': 'ru'
generatePurchaseUrl = wayforpay.generatePurchaseUrl(p)
console.log generatePurchaseUrl

