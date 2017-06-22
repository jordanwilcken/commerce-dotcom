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


update : Msg -> PlaceOrderModel.Model -> (PlaceOrderModel.Model, Cmd Msg)
update msg model =
  case msg of
    PostOrder ->
      (model, postAnOrder model)

    OrderPosted (Ok responseMessage) ->
      init

    OrderPosted (Err err)  ->
      (model, Cmd.none)
      

 {--   NewGif (Ok newUrl) ->
      (Model model.topic newUrl, Cmd.none)

    NewGif (Err _) ->
      (model, Cmd.none) --}



-- VIEW


view : PlaceOrderModel.Model -> Html Msg
view model =
  div [ class "quadrant-row" ]
    [ text "this content provided by Elm"
    , button [ class "submit-button", onClick PostOrder ] [ text "Place Order" ]
    ]
      {-- <h1>Place your order!</h1>

        <div class="quadrant-row">
          <div class="input-column">
            <button>Add Laptop</button>
            <button>Add Book</button>
            <button>Add Lamp</button>
          </div>
          <div class="output-column">
            <ul>
              <li>Book x 2 @ $17 each</li>
              <li>Laptop x 4 @ $350 each</li>
            </ul>
          </div>
        </div>
        <div class="quadrant-row">
          <div class="input-column">
            <button>Paypal</button>
            <button>Visa ending in 0123</button>
          </div>
          <div class="output-column">
            <p>$2000 will be charged to your Visa</p>
          </div>
        </div>
        <div class="quadrant-row">
          <div class="input-column">
            <button>4059 Mt Lee Dr. Hollywood, CA 90068</button>
            <button>2 Macquarie Street, Sydney</button>
          </div>
          <div class="output-column">
            <p>Deliver to 2 Macquarie Street, Sydney</p>
          </div>
        </div>
        <div class="quadrant-row">
          <button class="submit-button">Place Order</button>
        </div> --}



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
  

{-- getRandomGif : String -> Cmd Msg
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
