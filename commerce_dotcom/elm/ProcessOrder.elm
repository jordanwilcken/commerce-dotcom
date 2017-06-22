module ProcessOrder exposing (main)

-- Read more about this program in the official Elm guide:
-- https://guide.elm-lang.org/architecture/effects/http.html

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode
import Json.Encode

import WebSocket

type alias Model = { processingCount: Int}

main =
  Html.program
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


init : (Model, Cmd Msg)
init =
  (Model 0, Cmd.none)

type Msg =
  NewOrder String


-- UPDATE


update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    NewOrder theString ->
      ({ model | processingCount = model.processingCount + 1 }, Cmd.none)

-- VIEW


view : Model -> Html Msg
view model =
  div [ class "quadrant-row" ]
    [ text ((toString model.processingCount) ++ " orders currently in process.")
    ]

    {-- 
            <h1>Order Processing</h1>
        <div class="quadrant-row">
          <div class="input-column">
            <button>5 seconds</button><button>10 seconds</button><button>1 minute</button>
          </div>
          <div class="output-column">
            It currently takes 5 seconds to process an order.
          </div>
        </div>
        <div class="quadrant-row">
          <div class="panel panel-default order-panel">
            <div class="panel-heading order-heading">In-Progress Orders</div>
            <table class="table">
              <thead>
                <tr>
                  <th>id</th>
                  <th>details</th>
                  <th>status</th>
                </tr>
              </thead>
              <tbody>
                <tr><td>1</td><td>2 books, 2 lamps, 1 laptop</td><td>ready for shipping in 5 seconds</td></tr>
                <tr><td>2</td><td>5 lamps</td><td>ready for shipping in 7 seconds</td></tr>
              </tbody>
            </table>
          </div>
        </div>
        --}
-- SUBSCRIPTIONS


subscriptions : model -> Sub Msg
subscriptions model =
  WebSocket.listen "ws://localhost:7777/processing" NewOrder



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
