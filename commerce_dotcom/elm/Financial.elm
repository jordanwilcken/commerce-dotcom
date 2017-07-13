module Financial exposing (main)

-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import WebSocket
import Json.Decode as Decode
import Dict

import PlaceOrderView as View


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


init : (Model, Cmd Msg)
init =
  let
    initialFinancialData =
      [ FinancialData "Books" 0 0.0
      , FinancialData "Lamps" 0 0.0
      , FinancialData "Laptops" 0 0.0
      ]

    indexedData =
      indexData initialFinancialData
  in
    ({ profitMargin = 5, indexedFinancials = indexedData }, Cmd.none)


-- THE MODEL


type alias Model =
  { profitMargin : Int
  , indexedFinancials : Dict.Dict String FinancialData
  }


type alias FinancialData =
  { productDescription : String
  , unitsSold : Int
  , totalProfit : Float 
  }


-- UPDATE


type Msg
  = SetProfitMargin Int
  | NewFinancialData (Dict.Dict String FinancialData)
  | InvalidFinancialData String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetProfitMargin value ->
      ({ model | profitMargin = value }, Cmd.none)

    NewFinancialData financialData ->
      let
        updatedFinancials = model.indexedFinancials |> updateTheFinancials financialData
      in
        ({ model | indexedFinancials = updatedFinancials }, Cmd.none)

    InvalidFinancialData rawData ->
      (model, Cmd.none)


updateTheFinancials
  : Dict.Dict String FinancialData
  -> Dict.Dict String FinancialData
  -> Dict.Dict String FinancialData
updateTheFinancials
  priorData
  newData =
    let
      sumTheNumbers : String -> FinancialData -> Dict.Dict String FinancialData -> Dict.Dict String FinancialData
      sumTheNumbers productDescription data indexedData =
        let
          maybeValue =
            indexedData |> Dict.get productDescription

          newValue =
            case maybeValue of
              Just indexedValue ->
                FinancialData productDescription (indexedValue.unitsSold + data.unitsSold) (indexedValue.totalProfit + data.totalProfit)

              Nothing ->
                data
        in
          indexedData |> Dict.insert productDescription newValue

      combineFinancialData =
        Dict.foldl sumTheNumbers
    in
      combineFinancialData priorData newData
  

-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ h1 [] [ text "Commerce.com Financial Data" ]
    , View.quadrantRow
        [ View.inputColumn
          [ Html.button [ onClick (SetProfitMargin 5) ] [ text "5%" ]
          , Html.button [ onClick (SetProfitMargin 10) ] [ text "10%" ]
          , Html.button [ onClick (SetProfitMargin 15) ] [ text "15%" ]
          ]
        , View.outputColumn
          [ Html.text ("We currently have a " ++ toString model.profitMargin ++ "% profit margin on each item we sell.")
          ]
        ]
    , View.quadrantRow
        [ div [ class "panel panel-default order-panel" ]
            [ div [ class "panel-heading order-heading" ]
                [ div [] [ text "June" ] ]
            , viewFinancials model.indexedFinancials
            ]
        ]
    ]


viewFinancials : Dict.Dict String FinancialData -> Html msg
viewFinancials indexedFinancialData =
  let
    rows =
      indexedFinancialData
        |> Dict.values
        |> List.map toFinancialRow
  in
    Html.table [ class "table" ]
      [ Html.thead []
          [ Html.tr []
              [ th [] [ text "product" ]
              , th [] [ text "units sold" ]
              , th [] [ text "total profit" ]
              ]
          ]
      , Html.tbody [] rows
      ]


toFinancialRow : FinancialData -> Html msg
toFinancialRow financialData =
  Html.tr []
    [ td [] [ Html.text financialData.productDescription ]
    , td [] [ Html.text (financialData.unitsSold |> toString) ]
    , td [] [ Html.text (financialData.totalProfit |> toString) ]
    ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  let
    rawDataToMessage : String -> Msg
    rawDataToMessage rawData =
      case rawData |> toItemizedOrder of
        Err decodeError ->
          Debug.log decodeError
          InvalidFinancialData rawData

        Ok itemizedOrder ->
          itemizedOrder |> toFinancialDataMsg model.profitMargin
  in
    WebSocket.listen "ws://localhost:7777/processing" rawDataToMessage


-- OTHER FUNCTIONS


type alias ItemizedPurchaseOrder = List OrderItem

type alias OrderItem = { description: String, quantity: Int, unitPrice: Float }


toItemizedOrder : String -> Result String ItemizedPurchaseOrder
toItemizedOrder orderString =
  Decode.decodeString (Decode.field "itemizedPurchaseOrder" decodePurchaseOrder) orderString


decodePurchaseOrder : Decode.Decoder ItemizedPurchaseOrder
decodePurchaseOrder =
  Decode.list decodeOrderItem


decodeOrderItem : Decode.Decoder OrderItem
decodeOrderItem =
  Decode.map3 OrderItem
    (Decode.field "description" Decode.string)
    (Decode.field "quantity" Decode.int)
    (Decode.field "unitPrice" Decode.float)


toFinancialDataMsg : Int -> ItemizedPurchaseOrder -> Msg
toFinancialDataMsg profitMargin itemizedOrder =
  let
    indexedData =
      itemizedOrder
        |> List.map (toFinancialData profitMargin)
        |> indexData
  in
    NewFinancialData indexedData


toFinancialData : Int -> OrderItem -> FinancialData
toFinancialData profitMarginPercent orderItem =
  { productDescription = orderItem.description ++ "s"
  , unitsSold = orderItem.quantity
  , totalProfit
      = orderItem.unitPrice
      * (toFloat profitMarginPercent) / 100.0
      * (toFloat orderItem.quantity)
  }


indexData : List FinancialData -> Dict.Dict String FinancialData
indexData financialData =
  financialData
    |> List.map (\item -> (item.productDescription, item))
    |> Dict.fromList