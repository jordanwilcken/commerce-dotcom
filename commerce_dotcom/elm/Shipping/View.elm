module Shipping.View exposing (ordersTable)

import Html
import Html.Attributes exposing (class)


type alias Order =
  { id : String
  , shipTo : String
  , status : String
  , deliveryCountdown : Int
  }


ordersTable : List Order -> Html.Html msg
ordersTable orders =
  Html.div [ class "panel panel-default order-panel" ]
    [ Html.div [ class "panel-heading order-heading" ] [ Html.text "In-Progress Orders" ]
    , Html.table [ class "table" ]
        [ Html.thead []
            [ Html.tr []
                [ Html.th [] [ Html.text "id" ]
                , Html.th [] [ Html.text "delivering to" ]
                , Html.th [] [ Html.text "status" ]
                ]
            ]
        , Html.tbody [] (orders |> toRows)
        ]
    ]


toRows : List Order -> List (Html.Html msg)
toRows orders =
  let
    makeRow singleOrder =
      Html.tr []
        [ Html.td [] [ Html.text singleOrder.id ]
        , Html.td [] [ Html.text singleOrder.shipTo ]
        , Html.td [] [ Html.text singleOrder.status ]
        ]
  in
    orders |> List.map makeRow