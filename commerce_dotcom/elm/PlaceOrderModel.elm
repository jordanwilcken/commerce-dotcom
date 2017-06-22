module PlaceOrderModel exposing (Model, asJsonValue)

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