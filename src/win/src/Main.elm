module Main exposing (..)

import Browser exposing (Document)
import Browser.Events as BE
import Css as C
import Html.Attributes as A
import Html.Events as E
import Html.Styled as H exposing (Html)
import Json.Decode as D
import Json.Encode as En


todo =
    Debug.todo ""


main : Program () Model Msg
main =
    Browser.document
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        }



-- MODEL


type alias Model =
    { duration : Float
    , currentTime : Float
    , min : Float
    , max : Float
    , start : Maybe Float
    , end : Maybe Float
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { duration = 0
      , currentTime = 0
      , min = 0
      , max = 0
      , start = Nothing
      , end = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = VideoLoaded Float
    | Less
    | More
    | SetStart
    | SetEnd
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetEnd ->
            ( { model
                | end = Just model.currentTime
                , currentTime = model.duration / 2
                , min = 0
                , max = model.duration
              }
            , Cmd.none
            )

        SetStart ->
            ( { model
                | start = Just model.currentTime
                , currentTime = model.duration / 2
                , min = 0
                , max = model.duration
              }
            , Cmd.none
            )

        More ->
            ( { model
                | currentTime = (model.currentTime + model.max) / 2
                , min = model.currentTime
              }
            , Cmd.none
            )

        Less ->
            ( { model
                | currentTime = (model.currentTime + model.min) / 2
                , max = model.currentTime
              }
            , Cmd.none
            )

        VideoLoaded duration ->
            ( if model.duration == 0 then
                { model
                    | duration = duration
                    , currentTime = duration / 2
                    , max = duration
                }

              else
                model
            , Cmd.none
            )

        NoOp ->
            ( model, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    BE.onKeyDown <|
        D.map
            (\key ->
                case key of
                    "ArrowLeft" ->
                        Less

                    "ArrowRight" ->
                        More

                    _ ->
                        NoOp
            )
            (D.field "key" D.string)



-- VIEW


view : Model -> Document Msg
view model =
    { title = ""
    , body =
        [ H.videoS [ C.width "75%" ]
            [ -- A.attribute "controls" ""
              A.src "video.mp4"
            , A.property "currentTime" <| En.float model.currentTime
            , E.on "canplaythrough" <|
                D.map VideoLoaded <|
                    D.at [ "target", "duration" ] D.float
            ]
            []
        , if converged model.max model.min then
            H.div []
                [ H.button [ E.onClick SetStart ] [ H.text "Set Start" ]
                , H.button [ E.onClick SetEnd ] [ H.text "Set End" ]
                ]

          else
            H.text ""
        , H.text <| String.fromFloat <| model.currentTime
        , case ( model.start, model.end ) of
            ( Just start, Just end ) ->
                let
                    ms =
                        round <| (end - start) * 1000
                in
                H.div []
                    [ H.div []
                        [ H.text <|
                            prettyPrint <|
                                ms
                        ]
                    , H.div [] [ H.text <| String.fromInt ms ]
                    ]

            _ ->
                H.text ""
        ]
            |> H.withStyles []
    }


converged : Float -> Float -> Bool
converged a b =
    if convergedHelper a == convergedHelper b then
        True

    else
        False


convergedHelper : Float -> Int
convergedHelper =
    round << (*) 10000


prettyPrint : Int -> String
prettyPrint ms =
    (if ms >= 60000 then
        String.fromInt (ms // 60000) ++ ":"

     else
        ""
    )
        ++ (modBy 60000 ms
                // 1000
                |> String.fromInt
                |> String.padLeft 2 '0'
           )
        ++ "."
        ++ (ms
                |> modBy 1000
                |> String.fromInt
                |> String.padLeft 3 '0'
           )
