module ShipOrder exposing (main)

import Html
import Html.Attributes exposing (class)
import Html.Events exposing (onClick)
import Time
import WebSocket

import Shipping.Order
import Shipping.View


main =
  Html.program
    { init = init, view = view, update = update, subscriptions = subscriptions }


type alias Model = { orders : List Order, secondsToDeliver : Int }

type alias Order = Shipping.Order.Order


init : (Model, Cmd Msg)
init = (Model [] 5, Cmd.none)


type Msg
  = OrdersShipped (List Order)
  | UpdateCountdowns
  | SetSecondsToDeliver Int
  | Nevermind


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    OrdersShipped newlyShipped ->
      ({ model | orders = List.append model.orders newlyShipped }, Cmd.none)

    UpdateCountdowns ->
      let
        updatedOrders =
          Shipping.Order.tidy (Shipping.Order.updateOrders model.orders)
      in
        ({ model | orders = updatedOrders }, Cmd.none)

    SetSecondsToDeliver value ->
      ({ model | secondsToDeliver = value }, Cmd.none)

    Nevermind -> (model, Cmd.none)


view : Model -> Html.Html Msg
view model =
  Html.div []
    [ Html.h1 [] [ Html.text "Order Delivery" ]
    , Html.div [ class "quadrant-row "]
        [ Html.div [ class "input-column" ]
            [ Html.button [ onClick (SetSecondsToDeliver 5) ] [ Html.text "5 seconds" ]
            , Html.button [ onClick (SetSecondsToDeliver 10) ] [ Html.text "10 seconds" ]
            , Html.button [ onClick (SetSecondsToDeliver 60) ] [ Html.text "60 seconds" ]
            ]
        , Html.div [ class "output-column"]
            [ Html.text ("It currently takes " ++ (toString model.secondsToDeliver) ++ " seconds to deliver an order.")
            ]
        ]
    , Html.div [ class "quadrant-row "]
        [ Shipping.View.ordersTable model.orders
        ]
    ]


subscriptions : Model -> Sub Msg
subscriptions model =
  let
    socketSubscription =
      WebSocket.listen "ws://localhost:7777/shipping" (socketDataToMsg model.secondsToDeliver)

    timerSubscription =
      Time.every Time.second (\time -> UpdateCountdowns)
  in
    Sub.batch [ socketSubscription, timerSubscription ]


socketDataToMsg : Int -> String -> Msg
socketDataToMsg secondsToDeliver socketData =
  let
    toMsg : Result String (List Order) -> Msg
    toMsg decodeResult =
      case decodeResult of
        Ok orders ->
          OrdersShipped orders

        Err error ->
          Debug.log error
          Nevermind
  in
    socketData |> (Shipping.Order.decodeOrders secondsToDeliver) |> toMsg