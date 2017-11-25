module Main exposing (..)

import List
import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Material
import Material.Color as Color
import Material.Chip as Chip
import Material.Scheme
import Material.Layout as Layout
import Material.Table as Table
import Material.Grid exposing (grid, cell, size, Device(..))

type alias Interest = String
type alias CategoryName = String

type Category = Category CategoryName (List Interest)

type alias Tab =
    Int



-- MODEL

type alias Model =
    { mdl :
        Material.Model
        -- Boilerplate: model store for any and all Mdl components you use.
    , selectedTab : Tab
    , selectedCategories : List Category
    }


model : Model
model =
    { mdl =
        Material.model
        -- Boilerplate: Always use this initial Mdl model store.
    , selectedTab = 0
    , selectedCategories = [Category "foo" ["hehe"], Category "bar" [ "bing", "bang", "bong" ]]
    }



-- ACTION, UPDATE


type Msg
    = SelectTab Tab
    | AddPreference String
    | Mdl (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTab tab ->
            ( { model | selectedTab = tab }
            , Cmd.none
            )

        AddPreference pref ->
            ( model, Cmd.none )

        -- Boilerplate: Mdl action handler.
        Mdl msg_ ->
            Material.update Mdl msg_ model



-- VIEW


type alias Mdl =
    Material.Model


view : Model -> Html Msg
view model =
    Material.Scheme.topWithScheme Color.Teal Color.LightGreen <|
        Layout.render Mdl
            model.mdl
            [ Layout.fixedHeader
            , Layout.selectedTab model.selectedTab
            , Layout.onSelectTab SelectTab
            ]
            { header = [ h1 [ style [ ( "padding", "2rem" ) ] ] [ text "I-tinerary" ] ]
            , drawer = []
            , tabs = ( [ text "Preferences", text "Plan" ], [] )
            , main = [ pageLayout (mainBody model) ]
            }


pageLayout : Html Msg -> Html Msg
pageLayout html =
    grid []
        [ cell [ size All 4 ]
            [ html ]
        ]


mainBody : Model -> Html Msg
mainBody model =
    case model.selectedTab of
        0 ->
            preferencesView model

        _ ->
            text "error"


preferencesView : Model -> Html Msg
preferencesView model =
    let 
        preference : String -> Html Msg
        preference entry =
            Chip.span [] [ Chip.content [] [text entry] ]

        row : Category -> Html Msg
        row (Category name entries) =
        Table.tr []
            [ Table.td [] [ text name ]
            , Table.td [] (List.map preference entries)
            ]
    in
       Table.table []
            [Table.thead [] [], Table.tbody [] (List.map row model.selectedCategories)]


main : Program Never Model Msg
main =
    Html.program
        { init = ( model, Cmd.none )
        , view = view
        , subscriptions = always Sub.none
        , update = update
        }
