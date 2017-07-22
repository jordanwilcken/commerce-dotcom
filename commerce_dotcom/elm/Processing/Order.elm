module Processing.Order exposing (Order, toStatus, makeOrder, ordersToHttpBody)

import Http
import Json.Decode as Decode
import Json.Encode as Encode


type alias Order =
  { id: String
  , merchandise : String
  , countdown : Int
  , status : String
  , shipTo : String
  }


type alias OrderItem = { quantity: Int, description: String }


makeOrder : String -> Int -> String -> Result String Order
makeOrder id countdown stringData =
  let
    mapToOrder : String -> String -> Order
    mapToOrder merchandise shipTo =
      Order id merchandise countdown (countdown |> toStatus) shipTo

    merchandiseResult =
      decodeMerchandise stringData

    shipToResult =
      decodeShipTo stringData
  in
    Result.map2 mapToOrder merchandiseResult shipToResult


toMerchandise : List OrderItem -> String
toMerchandise orderItems =
  let
    stringFormatItem : OrderItem -> String
    stringFormatItem item =
      let
        description =
          if item.quantity > 1 then
            item.description ++ "s"

          else
            item.description
      in
        (toString item.quantity) ++ " " ++ description ++ "."
  in
    orderItems
      |> List.map stringFormatItem
      |> String.join "  "


toStatus : Int -> String
toStatus countdown =
  if countdown < 1 then
    "ready for shipping"

  else
    "ready for shipping in " ++ (toString countdown) ++ " seconds"


decodeMerchandise : String -> Result String String
decodeMerchandise data =
  let
    purchaseOrderDecoder =
      Decode.field "itemizedPurchaseOrder" (Decode.list orderItemDecoder)

    purchaseOrderResult =
      Decode.decodeString purchaseOrderDecoder data
  in
    purchaseOrderResult |> Result.map toMerchandise


orderItemDecoder : Decode.Decoder OrderItem
orderItemDecoder =
  let
    quantityDecoder =
      Decode.field "quantity" Decode.int

    descriptionDecoder =
      Decode.field "description" Decode.string
  in
    Decode.map2 OrderItem quantityDecoder descriptionDecoder
  

decodeShipTo : String -> Result String String
decodeShipTo data =
  Decode.decodeString (Decode.field "shipTo" Decode.string) data


ordersToHttpBody : List Order -> Http.Body
ordersToHttpBody orders =
  let
    encodedOrders =
      Encode.list (orders |> List.map encodeOrder)
  in
    Http.jsonBody encodedOrders


encodeOrder : Order -> Encode.Value
encodeOrder order =
  Encode.object
    [ ("id", (Encode.string order.id))
    , ("shipTo", (Encode.string order.shipTo))
    ]
