module Financial exposing (main)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import WebSocket
import Json.Decode as Decode
import Dict

import PlaceOrderView as View
import FinancialModel


main =
  Html.program
    { init = init, view = view, update = update, subscriptions = subscriptions }


init : (Model, Cmd Msg)
init =
  let
    initialFinancialData =
      [ FinancialModel.FinancialData "Books" 0 0
      , FinancialModel.FinancialData "Lamps" 0 0
      , FinancialModel.FinancialData "Laptops" 0 0
      ]

    indexedData =
      indexData initialFinancialData
  in
    ({ profitMargin = 5, indexedFinancials = indexedData }, Cmd.none)


indexData : List FinancialModel.FinancialData -> Dict.Dict String FinancialModel.FinancialData
indexData financialData =
  financialData
    |> List.map (\item -> (item.productDescription, item))
    |> Dict.fromList


-- THE MODEL


type alias Model = FinancialModel.Model


-- UPDATE


type Msg
  = SetProfitMargin Int
  | NewFinancialData (Dict.Dict String FinancialModel.FinancialData)
  | InvalidFinancialData String


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetProfitMargin value ->
      ({ model | profitMargin = value }, Cmd.none)

    NewFinancialData financialData ->
      let
        updatedFinancials =
          model.indexedFinancials |> FinancialModel.updateTheFinancials financialData
      in
        ({ model | indexedFinancials = updatedFinancials }, Cmd.none)

    InvalidFinancialData rawData ->
      (model, Cmd.none)


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


viewFinancials : Dict.Dict String FinancialModel.FinancialData -> Html msg
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


toFinancialRow : FinancialModel.FinancialData -> Html msg
toFinancialRow financialData =
  Html.tr []
    [ td [] [ Html.text financialData.productDescription ]
    , td [] [ Html.text (financialData.unitsSold |> toString) ]
    , td [] [ Html.text (financialData.totalProfit |> stringFormatCents) ]
    ]


stringFormatCents : Int -> String
stringFormatCents cents =
  cents
    |> toString
    |> String.padLeft 3 '0'
    |> (\centsString ->
          (String.dropRight 2 centsString) ++ "." ++ (String.right 2 centsString)
        )
    |> String.cons '$'


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  let
    rawDataToMessage : String -> Msg
    rawDataToMessage rawData =
      case rawData |> FinancialModel.decodePurchaseOrder of
        Err decodeError ->
          Debug.log decodeError
          InvalidFinancialData rawData

        Ok itemizedOrder ->
          itemizedOrder |> toFinancialDataMsg model.profitMargin
  in
    WebSocket.listen "ws://localhost:7777/processing" rawDataToMessage


toFinancialDataMsg : Int -> FinancialModel.ItemizedPurchaseOrder -> Msg
toFinancialDataMsg profitMargin itemizedOrder =
  let
    indexedData =
      itemizedOrder
        |> List.map (toFinancialData profitMargin)
        |> indexData
  in
    NewFinancialData indexedData


toFinancialData : Int -> FinancialModel.OrderItem -> FinancialModel.FinancialData
toFinancialData profitMarginPercent orderItem =
  { productDescription = orderItem.description ++ "s"
  , unitsSold = orderItem.quantity
  , totalProfit =
      let
        unitPrice =
          orderItem.unitPrice * 100 |> floor
      in
        toFloat (unitPrice * orderItem.quantity * profitMarginPercent) / 100.0 |> floor
  }