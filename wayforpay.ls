request = require('request')
crypto = require('crypto')
_ = require('lodash')
utf8 = require('utf8')


module.exports = (merchant_account, merchant_password) ->
  # API host
  console.log 'wayforpay'
  PURCHASE_URL = 'https://secure.wayforpay.com/pay'
  API_URL = 'https://api.wayforpay.com/api'
  WIDGET_URL = 'https://secure.wayforpay.com/server/pay-widget.js'
  FIELDS_DELIMITER = ';'
  API_VERSION = 1
  DEFAULT_CHARSET = 'utf8'
  MODE_PURCHASE = 'PURCHASE'
  MODE_SETTLE = 'SETTLE'
  MODE_CHARGE = 'CHARGE'
  MODE_REFUND = 'REFUND'
  MODE_CHECK_STATUS = 'CHECK_STATUS'
  MODE_P2P_CREDIT = 'P2P_CREDIT'
  MODE_CREATE_INVOICE = 'CREATE_INVOICE'
  MODE_P2_PHONE = 'P2_PHONE'
  COMPLETE_3DS = 'COMPLETE_3DS'
  @_action
  @_fields
  @_charset

  ###*
  # Call API
  #
  # @param Object fields
  #
  # @return Object
  ###

  @_query = (call) ->
    console.log '_query'
    data = JSON.stringify(@_fields)
    request.put {
      url: API_URL
      body: data
      headers: 'Content-Type': 'application/json; charset=utf-8'
    }, (error, response, body) ->
      if !error and response.statusCode == 200
        call body
      else
        call body
      return
    return

  ###*
  # Return signature hash
  #
  # @param action
  # @param fields
  # @return mixed
  ###

  @createSignature = (action, fields) ->
    @_prepare action, fields
    @_buildSignature()

  @_prepare = (action, fields) ->
    console.log '_prepare'
    @_action = action
    if _.isEmpty(fields)
      throw new Error('Arguments must be not empty')
    @_fields = fields
    @_fields.transactionType = action
    @_fields.merchantAccount = merchant_account
    @_fields.merchantSignature = @_buildSignature()
    if @_action != MODE_PURCHASE
      @_fields.apiVersion = API_VERSION
    @_checkFields()
    return

  ###*
  # MODE_SETTLE
  #
  # @param fields
  # @return mixed
  ###

  @settle = (fields, cb) ->
    @_prepare MODE_SETTLE, fields
    @_query cb

  ###*
  # MODE_CHARGE
  #
  # @param fields
  # @return mixed
  ###

  @charge = (fields, cb) ->
    @_prepare MODE_CHARGE, fields
    @_query cb

  ###*
  # MODE_REFUND
  #
  # @param fields
  # @return mixed
  ###

  @refund = (fields, cb) ->
    @_prepare MODE_REFUND, fields
    @_query cb

  ###*    "wayforpay": "0.0.1"

  # MODE_CHECK_STATUS
  #
  # @param fields
  # @return mixed
  ###

  @checkStatus = (fields, cb) ->
    @_prepare MODE_CHECK_STATUS, fields
    @_query cb

  ###*
  # COMPLETE_3DS
  #
  # @param fields
  # @return mixed
  ###

  @complete3ds = (fields, cb) ->
    @_prepare COMPLETE_3DS, fields
    @_query cb

  ###*
  # MODE_P2P_CREDIT
  #
  # @param fields
  # @return mixed
  ###

  @account2card = (fields, cb) ->
    @_prepare MODE_P2P_CREDIT, fields
    @_query cb

  ###*
  # MODE_P2P_CREDIT
  #
  # @param fields
  # @return mixed
  ###

  @createInvoice = (fields, cb) ->
    @_prepare MODE_CREATE_INVOICE, fields
    @_query cb

  ###*
  # MODE_P2P_CREDIT
  #
  # @param fields
  # @return mixed
  ###

  @account2phone = (fields, cb) ->
    @_prepare MODE_P2_PHONE, fields
    @_query cb

  ###*
  # MODE_PURCHASE
  # Generate html form
  #
  # @param fields
  # @return string
  ###

  @buildForm = (fields) ->
    @_prepare MODE_PURCHASE, fields
    form = '<form method="POST" action="' + PURCHASE_URL + '" accept-charset="utf-8">'
    _.each fields, (value, key) ->
      if _.isArray(key)
        _.each key, (fild) ->
          form += '<input type="hidden" name="' + key + '[]" value="' + fild + '" />'
          return
      else
        form += '<input type="hidden" name="' + key + '" value="' + value + '" />'
      return
    form += '<input type="submit" value="Submit purchase form"></form>'
    form

  ###*
  # MODE_PURCHASE
  # If GET redirect is used to redirect to purchase form, i.e.
  # https://secure.wayforpay.com/pay/get?merchantAccount=test_merch_n1&merchantDomainName=domain.ua&merchantSignature=c6d08855677ec6beca68e292b2c3c6ae&orderReference=RG3656-1430373125&orderDate=1430373125&amount=0.16&currency=UAH&productName=Saturn%20BUE%201.2&productPrice=0.16&productCount=1&language=RU
  #
  # @param fields
  # @return string
  ###

  @generatePurchaseUrl = (fields) ->
    @_prepare MODE_PURCHASE, fields
    PURCHASE_URL + '/get?' + serialize(fields)

  @_getFieldsNameForSignature = ->
    console.log '_getFieldsNameForSignature'
    purchaseFieldsAlias = [
      'merchantAccount'
      'merchantDomainName'
      'orderReference'
      'orderDate'
      'amount'
      'currency'
      'productName'
      'productCount'
      'productPrice'
    ]
    switch @_action
      when 'COMPLETE_3DS'
        return [
          'transactionType'
          'authorization_ticket'
          'd3ds_pares'
        ]
      when 'ACCEPT'
        return [
          'orderReference'
          'status'
          'time'
        ]
      when 'PURCHASE'
        return purchaseFieldsAlias
      when 'REFUND'
        return [
          'merchantAccount'
          'orderReference'
          'amount'
          'currency'
        ]
      when 'CHECK_STATUS'
        return [
          'merchantAccount'
          'orderReference'
        ]
      when 'CHARGE'
        return purchaseFieldsAlias
      when 'SETTLE'
        return [
          'merchantAccount'
          'orderReference'
          'amount'
          'currency'
        ]
      when MODE_P2P_CREDIT
        return [
          'merchantAccount'
          'orderReference'
          'amount'
          'currency'
          'cardBeneficiary'
          'rec2Token'
        ]
      when MODE_CREATE_INVOICE
        return purchaseFieldsAlias
      when MODE_P2_PHONE
        return [
          'merchantAccount'
          'orderReference'
          'amount'
          'currency'
          'phone'
        ]
      else
        throw new Error('Unknown transaction type: ' + @_action)
    return

  ###*
  # _checkFields
  #
  # @param Object fields
  #
  # @return status
  #
  # @throws InvalidArgumentException
  ###

  @_checkFields = ->
    console.log '_checkFields'
    required = @_getRequiredFields
    error = []
    parameters = @_fields
    _(required).forEach (item) ->
      if array_key_exists(item, parameters)
        if !parameters[item]
          error.push item
      else
        error.push item
      return
    if !_.isEmpty(error)
      #!_.isEmpty
      throw new Error('Missed required field(s): ' + JSON.stringify(error))
    true

  ###*
  # _buildSignature
  #
  # @param Object fields
  #
  # @return string
  ###

  @_buildSignature = ->
    console.log '_buildSignature'
    signFields = @_getFieldsNameForSignature()
    data = []
    error = []
    parameters = @_fields
    _(signFields).forEach (item) ->
      if array_key_exists(item, parameters)
        value = parameters[item]
        if _.isArray(value)
          arrParam = _.values(value)
          str = arrParam.join(FIELDS_DELIMITER)
          data.push str + ''
        else
          data.push value + ''
      else
        error.push item
      return
    if !_.isEmpty(error)
      throw new Error('Missed signature field(s): ' + JSON.stringify(error))
    arrParam = _.values(data)
    secret = arrParam.join(FIELDS_DELIMITER)
    buffer = utf8.encode(secret)
    hash = crypto.createHmac('md5', merchant_password).update(buffer).digest('hex')
    hash

  @_getRequiredFields = ->
    switch @_action
      when 'PURCHASE'
        return [
          'merchantAccount'
          'merchantDomainName'
          'merchantTransactionSecureType'
          'orderReference'
          'orderDate'
          'amount'
          'currency'
          'productName'
          'productCount'
          'productPrice'
        ]
      when 'SETTLE'
        return [
          'transactionType'
          'merchantAccount'
          'orderReference'
          'amount'
          'currency'
          'apiVersion'
        ]
      when 'ACCEPT'
        return [
          'orderReference'
          'status'
          'time'
        ]
      when 'CHARGE'
        required = [
          'transactionType'
          'merchantAccount'
          'merchantDomainName'
          'orderReference'
          'apiVersion'
          'orderDate'
          'amount'
          'currency'
          'productName'
          'productCount'
          'productPrice'
        ]
        additional = if @_fields['recToken'] then [ 'recToken' ] else [
          'card'
          'expMonth'
          'expYear'
          'cardCvv'
          'cardHolder'
        ]
        return required.concat(additional).unique()
      when 'REFUND'
        return [
          'transactionType'
          'merchantAccount'
          'orderReference'
          'amount'
          'currency'
          'comment'
          'apiVersion'
        ]
      when 'CHECK_STATUS'
        return [
          'transactionType'
          'merchantAccount'
          'orderReference'
          'apiVersion'
        ]
      when 'COMPLETE_3DS'
        return [
          'transactionType'
          'authorization_ticket'
          'd3ds_pares'
        ]
      when MODE_P2P_CREDIT
        return [
          'transactionType'
          'merchantAccount'
          'orderReference'
          'amount'
          'currency'
          'cardBeneficiary'
          'merchantSignature'
        ]
      when MODE_CREATE_INVOICE
        return [
          'transactionType'
          'merchantAccount'
          'merchantDomainName'
          'orderReference'
          'amount'
          'currency'
          'productName'
          'productCount'
          'productPrice'
        ]
      when MODE_P2_PHONE
        return [
          'merchantAccount'
          'orderReference'
          'orderDate'
          'currency'
          'amount'
          'phone'
          'apiVersion'
        ]
      else
        throw new Error('Unknown transaction type')
    return

  @buildWidgetButton = (fields, callback = null) ->
    @_prepare MODE_PURCHASE, fields
    button = '<script id="widget-wfp-script" language="javascript" type="text/javascript" src="' + WIDGET_URL + '"></script>'
    button += '<script type="text/javascript">'
    button += 'var wayforpay = new Wayforpay();'
    button += 'var pay = function () {'
    button += '    wayforpay.run(' + JSON.stringify(@_fields) + ');'
    button += '}'
    button += 'window.addEventListener("message", ' + (if callback then callback else 'receiveMessage') + ');'
    button += 'function receiveMessage(event)'
    button += '{'
    button += '    if('
    button += '        event.data == "WfpWidgetEventClose" ||      //при закрытии виджета пользователем'
    button += '        event.data == "WfpWidgetEventApproved" ||   //при успешном завершении операции'
    button += '        event.data == "WfpWidgetEventDeclined" ||   //при неуспешном завершении'
    button += '        event.data == "WfpWidgetEventPending")      // транзакция на обработке'
    button += '    {'
    button += '        console.log(event.data);'
    button += '    }'
    button += '}'
    button += '</script>'
    button += '<button type="button" onclick="pay();">Оплатить</button>'
    button

  #//refact

  serialize = (obj) ->
    str = []
    for p of obj
      if obj.hasOwnProperty(p)
        str.push encodeURIComponent(p) + '=' + encodeURIComponent(obj[p])
    str.join '&'

  array_key_exists = (key, search) ->
    if !search or search.constructor != Array and search.constructor != Object
      return false
    search[key] != undefined

  #//refactend
  this

# ---
# generated by js2coffee 2.2.0