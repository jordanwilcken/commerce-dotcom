module Shipping.Order exposing (Order, updateOrders, decodeOrders, tidy)

import Json.Decode as Decode


type alias Order =
  { id : String
  , shipTo : String
  , status : String
  , deliveryCountdown : Int
  }


updateOrders : List Order -> List Order
updateOrders orders =
  orders |> decrementCountdowns |> updateStatuses


tidy : List Order -> List Order
tidy orders =
  let
    delivered =
      orders |> List.filter (\order -> order.deliveryCountdown <= 0)

    deliveredCount = List.length delivered

    toRemove =
      List.take (deliveredCount - 5) delivered
  in
    Debug.log (toString (List.length toRemove))
    orders |> List.filter (\order -> not (List.member order toRemove))


decodeOrders : Int -> String -> Result String (List Order)
decodeOrders deliveryCountdown stringData =
  let
    idDecoder = Decode.field "id" Decode.string

    shipToDecoder = Decode.field "shipTo" Decode.string

    mapToOrder id shipTo =
      Order id shipTo (determineStatus deliveryCountdown) deliveryCountdown

    ordersDecoder =
      Decode.list (Decode.map2 mapToOrder idDecoder shipToDecoder)
  in
    Decode.decodeString ordersDecoder stringData


decrementCountdowns orders =
  let
    updateCountdown currentCountdown =
      if currentCountdown > 0 then
        currentCountdown - 1

      else
        currentCountdown
  in
    orders |> List.map (\order -> { order | deliveryCountdown = (order.deliveryCountdown |> updateCountdown) })


updateStatuses orders =
  let
    updateStatus singleOrder =
      { singleOrder | status = determineStatus singleOrder.deliveryCountdown }
  in
    orders |> List.map updateStatus


determineStatus : Int -> String
determineStatus countdown =
    if countdown <= 0 then
      "Delivered!"

    else
      "delivery in " ++ (toString countdown) ++ " seconds"
