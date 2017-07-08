module PlaceOrderView exposing (quadrantRow, inputColumn, outputColumn, itemizedPurchaseOrder, explainCharges)

import Html
import Html.Attributes exposing (..)

import PlaceOrderModel

quadrantRow : List (Html.Html msg) -> Html.Html msg
quadrantRow children =
  Html.div [ class "quadrant-row" ] children


inputColumn : List (Html.Html msg) -> Html.Html msg
inputColumn children =
  Html.div [ class "input-column" ] children


outputColumn : List (Html.Html msg) -> Html.Html msg
outputColumn children =
  Html.div [ class "output-column" ] children


itemizedPurchaseOrder : PlaceOrderModel.ItemizedPurchaseOrder -> Html.Html msg
itemizedPurchaseOrder itemizedOrder =
  let
    makeLi : PlaceOrderModel.OrderItem -> Html.Html msg
    makeLi orderItem =
      Html.li [] [ Html.text (stringify orderItem) ]

    toLiElements : PlaceOrderModel.ItemizedPurchaseOrder -> List (Html.Html msg)
    toLiElements itemizedOrder =
      itemizedOrder |> List.map makeLi
  in
    Html.ul [] (itemizedOrder |> toLiElements)


stringify: PlaceOrderModel.OrderItem -> String
stringify orderItem =
  let
    space = " "
    quantity = "x" ++ space ++ (toString orderItem.quantity)
    unitPrice = "$" ++ (toString orderItem.unitPrice.price) ++ space ++ orderItem.unitPrice.unit
  in
    orderItem.description ++ space ++ quantity ++ space ++ "@" ++ space ++ unitPrice


explainCharges : PlaceOrderModel.Model -> Html.Html msg
explainCharges model =
  let
    orderTotal =
      PlaceOrderModel.calculateOrderTotal model.itemizedPurchaseOrder

    paymentMethodText =
      if String.isEmpty model.paymentMethod then
        ""

      else
        " will be charged to your " ++ model.paymentMethod

    explanation =
      if orderTotal > 0.0 then
        "$" ++ (orderTotal |> toString) ++ paymentMethodText

      else
        ""
  in
    Html.p [] [ Html.text explanation ]