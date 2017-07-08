module PlaceOrder exposing (main)

-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode
import Json.Encode

import PlaceOrderModel
import PlaceOrderView as View


main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


init : (PlaceOrderModel.Model, Cmd Msg)
init =
  ( PlaceOrderModel.Model [] "" ""
  , Cmd.none
  )


-- UPDATE


type Msg
  = PostOrder
  | OrderPosted (Result Http.Error String)
  | ChangeOrder ChangeOrderMsg
  | SelectPaymentMethod String
  | SelectShipTo String


type ChangeOrderMsg
  = AddLaptop
  | AddBook
  | AddLamp


update : Msg -> PlaceOrderModel.Model -> (PlaceOrderModel.Model, Cmd Msg)
update msg model =
  case msg of
    ChangeOrder changeOrderMsg ->
      let
        changedPurchaseOrder = model.itemizedPurchaseOrder |> changeOrder changeOrderMsg
        newModel = { model | itemizedPurchaseOrder = changedPurchaseOrder }
      in
        (newModel, Cmd.none)

    SelectPaymentMethod selected ->
      ({ model | paymentMethod = selected }, Cmd.none)

    SelectShipTo selected ->
      ({ model | shipTo = selected }, Cmd.none)

    PostOrder ->
      (model, postAnOrder model)

    OrderPosted (Ok responseMessage) ->
      init

    OrderPosted (Err err) ->
      (model, Cmd.none)


changeOrder: ChangeOrderMsg -> PlaceOrderModel.ItemizedPurchaseOrder -> PlaceOrderModel.ItemizedPurchaseOrder
changeOrder changeOrderMsg itemizedPurchaseOrder =
  let
    newItem =
      changeOrderMsg |> toOrderItem
  in
    itemizedPurchaseOrder |> PlaceOrderModel.addOrderItem newItem
    

toOrderItem : ChangeOrderMsg -> PlaceOrderModel.OrderItem
toOrderItem changeOrderMsg =
  case changeOrderMsg of
    AddLaptop ->
      PlaceOrderModel.OrderItem "Laptop" 1 { price = 350.00, unit = "each" }

    AddBook ->
      PlaceOrderModel.OrderItem "Book" 1 { price = 19.99, unit = "each" }

    AddLamp ->
      PlaceOrderModel.OrderItem "Lamp" 1 { price = 39.00, unit = "each" }
      

-- VIEW


view : PlaceOrderModel.Model -> Html Msg
view model =
  div []
    [ h1 [] [ text "Place your order!" ]
    , View.quadrantRow
        [ View.inputColumn
            [ button [ onClick (ChangeOrder AddLaptop) ] [ text "Add Laptop" ]
            , button [ onClick (ChangeOrder AddBook) ] [ text "Add Book" ]
            , button [ onClick (ChangeOrder AddLamp) ] [ text "Add Lamp" ]
            ]
        , View.outputColumn
            [ View.itemizedPurchaseOrder model.itemizedPurchaseOrder
            ]
        ]
    , View.quadrantRow
        [ View.inputColumn
            [ button [ onClick (SelectPaymentMethod "Paypal account") ] [ text "Paypal account" ]
            , button [ onClick (SelectPaymentMethod "Visa ending in 0123") ] [ text "Visa ending in 0123" ]
            ]
        , View.outputColumn
            [ View.explainCharges model
            ]
        ]
    , View.quadrantRow
        [ View.inputColumn
            [ button [ onClick (SelectShipTo "4059 Mt Lee Dr. Hollywood, CA 90068") ] [ text "4059 Mt Lee Dr. Hollywood, CA 90068" ]
            , button [ onClick (SelectShipTo "2 Macquarie Street, Sydney") ] [ text "2 Macquarie Street, Sydney" ]
            ]
        , View.outputColumn
            [ p [] [ text (if String.isEmpty model.shipTo then "" else ("Deliver to " ++ model.shipTo)) ]
            ]
        ]
    , View.quadrantRow
        [ button [ onClick PostOrder ] [ text "Place Order" ]
        ]
    ]


-- SUBSCRIPTIONS


subscriptions : PlaceOrderModel.Model -> Sub Msg
subscriptions model =
  Sub.none


-- HTTP


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