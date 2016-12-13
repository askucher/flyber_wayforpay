WayForPay (Reviewed by Flyber)


###WayForPay provides few options how to charge user:

* IFrame
* Popup
* POST request (available only for organisations who has PCI DSS license)


If you have license definitely use "POST request" otherwise "IFrame"

This is "IFrame solution"

###How it works

1. You send request from your back-end server
2. Obtain payment url
3. Redirect your user to payment url

```
https://secure.wayforpay.com/pay/get?merchantDomainName=app.wepster.com&merchantTransactionSecureType=AUTO&serviceUrl=http%3A%2F%2Fyourdomain.com%2Fwfp%2Freturn&orderReference=orderid001&orderDate=14898322&amount=1.00&currency=USD&productName=product%20name&productPrice=2.00&productCount=2&language=ru&transactionType=PURCHASE&merchantAccount=test_merch_n1&merchantSignature=901874bb4df660cda5e3d0d3a4687bfe
```

4. User puts his credit card information
5. You obtain the token
6. You charge the users by his token 

###Moreover

Next Time you do not need to ask user for credit card again because you can reuse the token several times


###Example

```Javascript
  var WayForPay, wayforpay, p, generatePurchaseUrl;
  WayForPay = require('flyber_wayforpay');
  wayforpay = new WayForPay('test_merch_n1', 'flk3409refn54t54t*FNJRET');
  p = {
    'merchantDomainName': 'app.wepster.com',
    'merchantTransactionSecureType': 'AUTO',
    'serviceUrl': 'http://yourdomain.com/wfp/return',
    'orderReference': 'orderid001',
    'orderDate': '14898322',
    'amount': '1.00',
    'currency': 'USD',
    'productName': 'product name',
    'productPrice': '2.00',
    'productCount': '2',
    'language': 'ru'
  };
  generatePurchaseUrl = wayforpay.generatePurchaseUrl(p);
  console.log(generatePurchaseUrl);

```

![Flyber](http://res.cloudinary.com/nixar-work/image/upload/v1473975258/13268115_880281065449309_626424912755329334_o.jpg)

http://flyber.net