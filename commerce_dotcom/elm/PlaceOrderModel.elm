module PlaceOrderModel exposing
  ( Model
  , OrderItem
  , UnitPrice
  , ItemizedPurchaseOrder
  , asJsonValue
  , addOrderItem
  , calculateOrderTotal
  )

import Json.Encode

type alias Model =
  { itemizedPurchaseOrder : ItemizedPurchaseOrder
  , paymentMethod : String
  , shipTo : String
  }

type alias ItemizedPurchaseOrder = List OrderItem

type alias OrderItem = { description: String, quantity: Int, unitPrice: UnitPrice }

type alias UnitPrice = { price: Float, unit: String }

asJsonValue : Model -> Json.Encode.Value
asJsonValue model =
  Json.Encode.object
    [ ("shipTo", (Json.Encode.string model.shipTo))
    , ("itemizedPurchaseOrder", (encodePurchaseOrder model.itemizedPurchaseOrder))
    ]


addOrderItem : OrderItem -> ItemizedPurchaseOrder -> ItemizedPurchaseOrder
addOrderItem newItem purchaseOrder =
  let
    productNotYetInOrder =
      checkProductInOrder purchaseOrder newItem
      |> not

    whereDescriptionMatches: OrderItem -> Bool
    whereDescriptionMatches item =
      item.description == newItem.description
  in
    if productNotYetInOrder then
      List.append purchaseOrder (List.singleton newItem)

    else
      purchaseOrder |> increaseQuantityBy newItem.quantity whereDescriptionMatches


checkProductInOrder: ItemizedPurchaseOrder -> OrderItem -> Bool
checkProductInOrder purchaseOrder orderItem =
  let
    descriptions = purchaseOrder |> List.map (\item -> item.description)
  in
    List.member orderItem.description descriptions


increaseQuantityBy : Int -> (OrderItem -> Bool) -> ItemizedPurchaseOrder -> ItemizedPurchaseOrder
increaseQuantityBy amount markedForChange purchaseOrder =
  let
    changeQuantity: OrderItem -> OrderItem
    changeQuantity item =
      if item |> markedForChange then
        { item | quantity = item.quantity + amount }

      else
        item
  in
    purchaseOrder |> List.map changeQuantity


encodePurchaseOrder : ItemizedPurchaseOrder -> Json.Encode.Value
encodePurchaseOrder purchaseOrder =
  Json.Encode.list (purchaseOrder |> List.map encodeOrderItem)


encodeOrderItem : OrderItem -> Json.Encode.Value
encodeOrderItem item =
  Json.Encode.object
    [ ("description", (Json.Encode.string item.description))
    , ("quantity", (Json.Encode.int item.quantity))
    , ("unitPrice", (Json.Encode.float item.unitPrice.price))
    ]


calculateOrderTotal : ItemizedPurchaseOrder -> Float
calculateOrderTotal purchaseOrder =
  purchaseOrder |> List.foldl (\item total -> total + ((toFloat item.quantity) * item.unitPrice.price)) 0.0