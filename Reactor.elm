module Reactor exposing (..)

import Main exposing (..)
import Html

main : Program Never Model Msg
main =
    Html.program
        { init = init { user = "test", baseUrl = "foo" }
        , view = view
        , update = update
        , subscriptions = always Sub.none
        }
