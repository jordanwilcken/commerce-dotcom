module ProcessOrder exposing (main)

import Html
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Http
import WebSocket
import Time

import Processing.Order


main =
  Html.program
    { init = init, view = view, update = update, subscriptions = subscriptions }


init : (Model, Cmd Msg)
init =
  let
    initialModel = { secondsToProcess = 5, orders = [], ordersReceivedCount = 0 }
  in
    (initialModel, Cmd.none)


-- MODEL

type alias Order = Processing.Order.Order


type alias Model =
  { secondsToProcess : Int
  , orders : List Order
  , ordersReceivedCount : Int
  }


-- UPDATE


type Msg
  = SetSecondsToProcess Int
  | OrderReceived Order
  | UpdateCountdowns
  | PostOrders (List Processing.Order.Order)
  | OrdersPosted (Result Http.Error String)
  | Nevermind


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    SetSecondsToProcess seconds ->
      ({ model | secondsToProcess = seconds }, Cmd.none)

    OrderReceived received ->
      let
        updatedModel =
          { model
            | orders = List.append model.orders [ received ]
            , ordersReceivedCount = model.ordersReceivedCount + 1
          }
      in
        (updatedModel, Cmd.none)

    UpdateCountdowns ->
      let
        updatedOrders = model.orders |> updateCountdowns |> updateStatuses
      in
        ({ model | orders = updatedOrders }, makeCommand updatedOrders)

    PostOrders orders ->
      (model, Cmd.none)

    OrdersPosted result ->
      (model, Cmd.none)

    Nevermind -> (model, Cmd.none)


updateCountdowns : List Processing.Order.Order -> List Processing.Order.Order
updateCountdowns orders =
  orders |> List.map (\order -> { order | countdown = order.countdown - 1 })


updateStatuses : List Processing.Order.Order -> List Processing.Order.Order
updateStatuses orders =
  orders |> List.map (\order -> { order | status = order.countdown |> Processing.Order.toStatus})


makeCommand : List Processing.Order.Order -> Cmd Msg
makeCommand orders =
  let
    readyForShipping =
      orders |> List.filter (\order -> order.status == "ready for shipping")
  in
    if List.isEmpty readyForShipping then
      Cmd.none

    else
      postOrders readyForShipping


postOrders : List Processing.Order.Order -> Cmd Msg
postOrders ordersToShip =
  Cmd.none
--  Http.send OrdersPosted (Http.post "../shipped-orders" (ordersToShip |> toRequestBody) decodeResponseMessage)


-- VIEW


view : Model -> Html.Html Msg
view model =
  Html.div []
    [ Html.h1 [] [ Html.text "Order Processing" ]
    , Html.div [ class "quadrant-row" ]
        [ Html.div [ class "input-column" ]
            [ Html.button [ onClick <| SetSecondsToProcess 5 ] [ Html.text "5 seconds" ]
            , Html.button [ onClick <| SetSecondsToProcess 10 ] [ Html.text "10 seconds" ]
            , Html.button [ onClick <| SetSecondsToProcess 60 ] [ Html.text "1 minute" ]
            ]
        , Html.div [ class "output-column" ]
            [ Html.text
                <| "It currently takes "
                ++ (toString model.secondsToProcess)
                ++ " seconds to process an order."
            ]
        ]
    , Html.div [ class "quadrant-row" ]
       [ Html.div [ class "panel panel-default order-panel" ]
            [ Html.div [ class "panel-heading order-heading" ]
                [ Html.div [] [ Html.text "In-Progress Orders" ] ]
            , viewOrders model.orders
            ]
        ]
    ]


viewOrders : List Processing.Order.Order -> Html.Html msg
viewOrders orders =
  Html.table [ class "table" ]
    [ Html.thead []
        [ Html.tr []
            [ Html.th [] [ Html.text "id" ]
            , Html.th [] [ Html.text "details" ]
            , Html.th [] [ Html.text "status" ]
            ]
        ]
    , Html.tbody [] (orders |> List.map orderToRow)
    ]


orderToRow : Processing.Order.Order -> Html.Html msg
orderToRow order =
  Html.tr []
    [ Html.td [] [ Html.text order.id ]
    , Html.td [] [ Html.text order.merchandise ]
    , Html.td [ class "status-cell" ] [ Html.text order.status ]
    ]


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  let
    id =
      toString (model.ordersReceivedCount + 1)

    makeOrder : String -> Result String Order
    makeOrder socketData =
      Processing.Order.makeOrder id model.secondsToProcess socketData

    subscriptions =
      [ WebSocket.listen "ws://localhost:7777/processing" (makeOrder >> makeOrderMessage)
      , Time.every Time.second (\time -> UpdateCountdowns)
      ]
  in
    Sub.batch subscriptions


makeOrderMessage : Result String Order -> Msg
makeOrderMessage orderResult =
  case orderResult of
    Err error ->
      Debug.log error
      Nevermind

    Ok order -> OrderReceived order

-- HTTP
{--
postAnOrder : PlaceOrderModel.Model -> Cmd Msg
postAnOrder model =
  Http.send OrderPosted (Http.post "../orders" (model |> toRequestBody) decodeResponseMessage)

toRequestBody : PlaceOrderModel.Model -> Http.Body
toRequestBody model =
  model
  |> PlaceOrderModel.asJsonValue
  |> Http.jsonBody

decodeResponseMessage : Json.Decode.Decoder String
decodeResponseMessage =
  Json.Decode.field "message" Json.Decode.string
  

getRandomGif : String -> Cmd Msg
getRandomGif topic =
  let
    url =
      "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
  in
    Http.send NewGif (Http.get url decodeGifUrl)


decodeGifUrl : Decode.Decoder String
decodeGifUrl =
  Decode.at ["data", "image_url"] Decode.string
  --}
