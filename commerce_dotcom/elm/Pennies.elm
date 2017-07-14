module Pennies exposing
  ( MinimumZero(Zero)
  , Pennies(Pennies)
  , zeroPennies
  , addPennies
  , toDollarsAndCents
  , toPennies
  , toInt)

type MinimumZero
  = NotZero Int
  | Zero

type Pennies = Pennies MinimumZero


zeroPennies : Pennies
zeroPennies =
  Pennies Zero

toDollarsAndCents : Pennies -> String
toDollarsAndCents pennies =
  case pennies of
    Pennies (NotZero amount) ->
      amount
        |> toString
        |> String.padLeft 2 '0'
        |> (\pennyString ->
             (String.dropRight 2 pennyString) ++ "." ++ (String.right 2 pennyString)
           )
        |> String.cons '$'

    Pennies Zero ->
      "$0.00"


toPennies : Int -> Pennies
toPennies someInt =
  if someInt > 0 then
    Pennies (NotZero someInt)

  else
    Pennies Zero


addPennies : Pennies -> Pennies -> Pennies
addPennies pennies otherPennies =
  let
    amount =
      (toInt pennies) + (toInt otherPennies)
  in
    toPennies amount


toInt : Pennies -> Int
toInt pennies =
  case pennies of
    Pennies (NotZero amount) -> amount

    Pennies Zero -> 0