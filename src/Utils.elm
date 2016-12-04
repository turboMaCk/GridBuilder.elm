module Utils exposing (..)

import Types exposing (GridPosition, GridSize)


isInRange : Int -> Int -> Int -> Bool
isInRange min max value =
    value >= min && value < max


isTaken :
    List ( GridPosition, GridSize )
    -> GridPosition
    -> Bool
isTaken grid position =
    let
        conflictX : GridPosition -> GridSize -> Bool
        conflictX pos item =
            isInRange pos.x (item.width + pos.x) position.x

        conflictY : GridPosition -> GridSize -> Bool
        conflictY pos item =
            isInRange pos.y (item.height + pos.y) position.y
    in
        List.isEmpty
            (List.filter
                (\( position, item ) -> (conflictX position item) && (conflictY position item))
                grid
            )
            |> not


getPosition :
    (a -> GridSize)
    -> Int
    -> List ( GridPosition, a )
    -> a
    -> ( GridPosition, a )
getPosition getSize perRow grid originalItem =
    let
        item : GridSize
        item =
            getSize originalItem

        last : Maybe ( GridPosition, GridSize )
        last =
            List.reverse grid |> List.head |> Maybe.map (\(pos, a) -> (pos, getSize a))

        nextPosition : GridPosition -> GridPosition
        nextPosition position =
            if position.x + item.width < perRow then
                { x = position.x + 1, y = position.y }
            else
                { x = 0, y = position.y + 1 }

        firstTryPosition : GridPosition
        firstTryPosition =
            case last of
                Just ( lastPosition, lastItem ) ->
                    nextPosition
                        { x = lastPosition.x + lastItem.width - 1
                        , y = lastPosition.y
                        }

                Nothing ->
                    { x = 0, y = 0 }

        tryPosition : GridPosition -> GridPosition
        tryPosition position =
            let
                subCollisions =
                    List.range 0 (item.width - 1)
                        |> List.filter (\i -> isTaken (List.map (\(pos, a) -> (pos, getSize a)) grid) { x = position.x + i, y = position.y })
            in
                if List.isEmpty subCollisions then
                    position
                else
                    tryPosition (nextPosition position)
    in
        ( (tryPosition firstTryPosition), originalItem )
