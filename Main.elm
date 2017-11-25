module Main exposing (..)

import List
import Http
import Html exposing (..)
import Html.Attributes exposing (href, class, style)
import Material
import Material.Button as Button
import Material.Color as Color
import Material.Chip as Chip
import Material.Card as Card
import Material.Icon as Icon
import Material.Footer as Footer
import Material.Options as Options
import Material.Scheme
import Material.Layout as Layout
import Material.Table as Table
import Material.Grid exposing (grid, cell, size, Device(..))
import Json.Decode as Decode


type alias Tab =
    Int


type alias User =
    String


type alias Interest =
    String


type alias CategoryName =
    String


type Category
    = Category CategoryName (List Interest)


type alias Preferences =
    List Category


type alias Event =
    { name : String
    , url : String
    , photoUrl : String
    , price : Int
    }


type alias Itinerary =
    List Event



-- MODEL


type alias Model =
    { mdl :
        Material.Model
        -- Boilerplate: model store for any and all Mdl components you use.
    , selectedTab : Tab
    , selectedUser : User
    , selectedPreferences : Preferences
    , selectedItinerary : Itinerary
    }


model : Model
model =
    { mdl =
        Material.model
        -- Boilerplate: Always use this initial Mdl model store.
    , selectedTab = 0
    , selectedUser = "test"
    , selectedPreferences = [ Category "foo" [ "hehe" ], Category "bar" [ "bing", "bang", "bong" ] ]
    , selectedItinerary =
        [ { name = "foo", url = "", photoUrl = "", price = 0 }
        , { name = "bar", url = "", photoUrl = "https://pbs.twimg.com/media/DPaWvjFUMAEoSgO.jpg:large", price = 0 }
        ]
    }



-- ACTION, UPDATE


type Msg
    = SelectTab Tab
    | GetUser User
    | NewUser (Result Http.Error String)
    | AddPreference String
    | Mdl (Material.Msg Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SelectTab tab ->
            ( { model | selectedTab = tab }
            , Cmd.none
            )

        GetUser user ->
            ( model, getUser user )

        NewUser (Ok user) ->
            ( { model | selectedUser = user }
            , Cmd.none
            )

        NewUser (Err _) ->
            ( model
            , Cmd.none
            )

        AddPreference pref ->
            ( model, Cmd.none )

        -- Boilerplate: Mdl action handler.
        Mdl msg_ ->
            Material.update Mdl msg_ model


getUser : User -> Cmd Msg
getUser user =
    let
        url : String
        url =
            "/user/" ++ user

        request =
            Http.get url decodeUser
    in
        Http.send NewUser request


decodeUser : Decode.Decoder String
decodeUser =
    Decode.at [ "data", "user" ] Decode.string



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
            , main = [ pageLayout (mainBody model), footer ]
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
            preferencesView model.selectedPreferences

        1 ->
            itineraryView model.selectedItinerary

        _ ->
            text "error"


preferencesView : Preferences -> Html Msg
preferencesView preferences =
    let
        interest : Interest -> Html Msg
        interest entry =
            Chip.span [] [ Chip.content [] [ text entry ] ]

        row : Category -> Html Msg
        row (Category name entries) =
            Table.tr []
                [ Table.td [] [ text name ]
                , Table.td [] (List.map interest entries)
                ]
    in
        Table.table []
            [ Table.thead []
                [ Table.th [] [ text "Category" ]
                , Table.th [] [ text "Preferences" ]
                ]
            , Table.tbody [] (List.map row preferences)
            ]


itineraryView : Itinerary -> Html Msg
itineraryView itinerary =
    let
        white =
            Color.text Color.white

        card : Event -> Html Msg
        card event =
            Card.view
                [ Color.background (Color.color Color.Pink Color.S500) ]
                [ Card.media
                    [ Options.css "background" ("url('" ++ event.photoUrl ++ "') center / cover")
                    , Options.css "height" "225px"
                    ]
                    []
                , Card.title []
                    [ Card.head [] [ text event.name ] ]
                , Card.menu []
                    [ Button.render Mdl
                        [ 0, 0 ]
                        model.mdl
                        [ Button.icon
                        , Button.ripple
                        , white
                        , Button.link event.url
                        ]
                        [ Icon.i "public" ]
                    ]
                ]
    in
        grid []
            [ cell [ size All 4 ]
                (List.map card itinerary)
            ]


footer : Html Msg
footer =
    Footer.mini []
        { left =
            Footer.left []
                [ Footer.logo [] [ Footer.html <| text "Mini Footer Example" ]
                , Footer.links []
                    [ Footer.linkItem [ Footer.href "#footers" ] [ Footer.html <| text "Link 1" ]
                    , Footer.linkItem [ Footer.href "#footers" ] [ Footer.html <| text "Link 2" ]
                    , Footer.linkItem [ Footer.href "#footers" ] [ Footer.html <| text "Link 3" ]
                    ]
                ]
        , right =
            Footer.right []
                [ Footer.logo [] [ Footer.html <| text "Mini Footer Right Section" ]
                , Footer.socialButton [ Options.css "margin-right" "6px" ] []
                , Footer.socialButton [ Options.css "margin-right" "6px" ] []
                , Footer.socialButton [ Options.css "margin-right" "0px" ] []
                ]
        }


main : Program Never Model Msg
main =
    Html.program
        { init = ( model, Cmd.none )
        , view = view
        , subscriptions = always Sub.none
        , update = update
        }
