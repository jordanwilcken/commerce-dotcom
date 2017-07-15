module FinancialModel exposing
  ( Model
  , FinancialData
  , Cents
  , updateTheFinancials
  , ItemizedPurchaseOrder
  , OrderItem
  , decodePurchaseOrder
  )

import Json.Decode as Decode
import Dict


type alias OrderItem =
  { description: String
  , quantity: Int
  , unitPrice: Float
  }


type alias Model =
  { profitMargin : Int
  , indexedFinancials : Dict.Dict String FinancialData
  }


type alias FinancialData =
  { productDescription : String
  , unitsSold : Int
  , totalProfit : Cents 
  }

type alias Cents = Int

type alias ItemizedPurchaseOrder = List OrderItem


updateTheFinancials
  : Dict.Dict String FinancialData
  -> Dict.Dict String FinancialData
  -> Dict.Dict String FinancialData
updateTheFinancials
  priorData
  newData =
    let
      combineFinancialData =
        Dict.foldl sumTheNumbers
    in
      combineFinancialData priorData newData
  

sumTheNumbers
  : String
  -> FinancialData
  -> Dict.Dict String FinancialData
  -> Dict.Dict String FinancialData
sumTheNumbers productDescription data indexedData =
  let
    maybeValue =
      indexedData |> Dict.get productDescription

    newValue =
      case maybeValue of
        Just indexedValue ->
          FinancialData
            productDescription
            (indexedValue.unitsSold + data.unitsSold)
            (indexedValue.totalProfit + data.totalProfit)

        Nothing ->
          data
  in
    indexedData |> Dict.insert productDescription newValue


decodePurchaseOrder : String -> Result String ItemizedPurchaseOrder
decodePurchaseOrder orderString =
  let
    purchaseOrderDecoder =
      Decode.list decodeOrderItem
  in
    Decode.decodeString (Decode.field "itemizedPurchaseOrder" purchaseOrderDecoder) orderString


decodeOrderItem : Decode.Decoder OrderItem
decodeOrderItem =
  Decode.map3 OrderItem
    (Decode.field "description" Decode.string)
    (Decode.field "quantity" Decode.int)
    (Decode.field "unitPrice" Decode.float)