{-# LANGUAGE Haskell98 #-}
-- cat file | ./leer línea

-- | Módulo principal - Main
module Main where

import Control.Monad
import Data.Char
import System.Random

-- | Sinónimo de tipo
type Tablero = String

-- | Muestra el tablero considerando el contenido que se leyó del archivo
mostrarTablero :: Tablero -> String
mostrarTablero tablero =
  "+---+---+---+\n" ++
  "|   |   |   |\n" ++
  "| " ++ tablero !! 0 : [] ++ " | " ++ tablero !! 1 : [] ++ " | " ++ tablero !! 2 : []  ++ " |\n" ++
  "|   |   |   |\n" ++
  "+---+---+---+\n" ++
  "|   |   |   |\n" ++
  "| " ++ tablero !! 3 : [] ++ " | " ++ tablero !! 4 : [] ++ " | " ++ tablero !! 5 : []  ++ " |\n" ++
  "|   |   |   |\n" ++
  "+---+---+---+\n" ++
  "|   |   |   |\n" ++
  "| " ++ tablero !! 6 : [] ++ " | " ++ tablero !! 7 : [] ++ " | " ++ tablero !! 8 : []  ++ " |\n" ++
  "|   |   |   |\n" ++
  "+---+---+---+\n"

-- | Asigna un puntaje
scoreBoard :: Tablero -> Char -> Int
scoreBoard board player
  | (ganador board) == ' '     = 0
  | (ganador board) == player  = 1
  | otherwise                 = -1

-- | scores the board and returns minimum value move for the given board
evaluateBoardMin :: Tablero -> Int
evaluateBoardMin tablero
  | length (movPermitidos tablero) == 0    = scoreBoard tablero 'O'
  | otherwise = foldr max (head scores) (tail scores)
  where
  tableros = map (mover tablero 'O') (movPermitidos tablero)
  scores = map evaluateBoardMax tableros

-- | scores the board and returns maximum value move for the given board
evaluateBoardMax :: Tablero -> Int
evaluateBoardMax tablero
  | length (movPermitidos tablero) == 0    = scoreBoard tablero 'O'
  | otherwise = foldr min (head scores) (tail scores)
  where
  tableros = map (mover tablero 'X') (movPermitidos tablero)
  scores = map evaluateBoardMin tableros

-- | Retorna una lista de tuplas (movimiento, puntaje)
scoreMoves :: Tablero -> [(Int, Int)]
scoreMoves tablero = zip (movPermitidos tablero) scores
  where
  tableros = map (mover tablero 'O') (movPermitidos tablero)
  scores = map evaluateBoardMax tableros

-- | De dos tuplas (movimiento, puntaje) devuelve la de mayor puntaje
maxScore :: (Int, Int) -> (Int, Int) -> (Int, Int)
maxScore (m0, s0) (m1, s1)
  | s0 > s1 = (m0, s0)
  | otherwise = (m1, s1)

-- | Dado un tablero elige una posición que asegura no se pierde
mejorMovimiento :: Tablero -> Int
mejorMovimiento tablero = movimiento
  where
  scored = scoreMoves tablero
  (movimiento, score) = foldr maxScore (head scored) (tail scored)


-- | Omite los espacios y saltos de línea que se leyeron del archivo
unaLinea :: Tablero -> String
unaLinea xs = [x | x <- xs, x/='\n', x/=' ']

-- | Retorna verdadero si el movimiento es válido
esValido :: Tablero -> Int -> Bool
esValido tablero p
  | p < 0 || p >= 9           = False   -- out of range
  | tablero !! p == 'E'       = True    -- empty
  | otherwise                 = False   -- played

-- | Arma una lista con todas posiciones vacías.
movPermitidos :: Tablero -> [Int]
movPermitidos tablero
  | (ganador tablero) /= ' ' = []
  | otherwise = [y | y <- [0..8], (esValido tablero y)]

-- | Verifica cada línea vertical, horizontal y diagonal en busca de un ganador
-- | Si lo encuentra devuelve el ganador (X u O), sino devuelve caracter vacío
ganador :: Tablero -> Char
ganador t
  -- Líneas horizontales
  | (t !! 0) /= 'E' && ((t !! 0) == (t !! 1) && (t !! 0) == (t !! 2)) = t !! 0
  | (t !! 3) /= 'E' && ((t !! 3) == (t !! 4) && (t !! 3) == (t !! 5)) = t !! 3
  | (t !! 6) /= 'E' && ((t !! 6) == (t !! 7) && (t !! 6) == (t !! 8)) = t !! 6
  -- Líneas verticales
  | (t !! 0) /= 'E' && ((t !! 0) == (t !! 3) && (t !! 0) == (t !! 6)) = t !! 0
  | (t !! 1) /= 'E' && ((t !! 1) == (t !! 4) && (t !! 1) == (t !! 7)) = t !! 1
  | (t !! 2) /= 'E' && ((t !! 2) == (t !! 5) && (t !! 2) == (t !! 8)) = t !! 2
  -- Líneas diagonales
  | (t !! 0) /= 'E' && ((t !! 0) == (t !! 4) && (t !! 0) == (t !! 8)) = t !! 0
  | (t !! 2) /= 'E' && ((t !! 2) == (t !! 4) && (t !! 2) == (t !! 6)) = t !! 2
  -- No hay ganador
  | otherwise = ' '

-- | Verifica que el formato del estado de juego obtenido del archivo sea válido
formato :: Tablero -> Bool
formato tablero
  | abs(x-o)<=1 && x + o + e == 9 = True
  | otherwise = False
  where
  (x,o,e)=(cantX tablero, cantO tablero, cantE tablero)

-- | Define que jugador tiene el siguiente turno
prox_jugador :: Tablero -> Char
prox_jugador tablero
  | cantX tablero < cantO tablero = 'X'
  | otherwise = 'O'

-- | Cuenta la cantidad de 'X'
cantX :: Tablero -> Int
cantX xs = sum [1 | x<-xs, x=='X']

-- | Cuenta la cantidad de 'O'
cantO :: Tablero -> Int
cantO xs = sum [1 | x<-xs, x=='O']

-- | Cuenta la cantidad de 'E'
cantE :: Tablero -> Int
cantE xs = sum [1 | x<-xs, x=='E']


-- | new mover applied
mover :: Tablero -> Char -> Int -> Tablero
mover (p:tablero) ch pos
  | pos > 0 = p:[] ++ (mover tablero ch (pos - 1))
  | otherwise = ch:[] ++ tablero

-- | Empieza el juego con un estado recibido desde main
-- | y finaliza cuando encuentra un ganador o no se pueden hacer más movimientos
juego :: String -> IO()
juego tablero = do
  putStr $ mostrarTablero tablero
  if not $ formato tablero
    then error "Formato de archivo inválido"
    else do
      if (ganador tablero) /= ' '
        then putStrLn $ "\nEl ganador es" ++ show (ganador tablero) ++ "\n"
        else do
          if 'X' == (prox_jugador tablero)
            then do
              num <- randomRIO (1,length (movPermitidos tablero)-1) :: IO Int
              juego (mover tablero 'X' ((movPermitidos tablero)!!num))
            else do
              juego (mover tablero 'O' (mejorMovimiento tablero))


-- | Función principal
main :: IO ()
main = do
    --  Lee contenido de un archivo y lo guarda en cadena
    cadena <- getContents
    let tablero = unaLinea cadena
    --  Imprime el tablero
    putStrLn "\nParadigmas de programación\n--------------------------\nTA TE TI\n--------\n"
    juego tablero
