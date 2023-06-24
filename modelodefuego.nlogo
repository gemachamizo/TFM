globals [
  initial-trees
  burned-trees
]


to setup
  clear-all
  set-default-shape turtles "square"
  ;; establece tantas casillas verdes como se haya indicado en la proporción
  ;; de material combustible
  let num-patches round (cantidad-de-vegetacion / 100 * count patches)
  ask n-of num-patches patches [
    set pcolor green
  ]
  ; establece una tortuga roja en alguna de las casillas verdes y la incendia
  ask one-of patches with [pcolor = green] [
  sprout 1 [
    set shape "square"
    set color red
    ask patch-here [ ignite ]   ;; se inicia el incendio en la primera casilla
     ]
   ]

  set initial-trees num-patches
  set burned-trees 0
  reset-ticks
end


to go
  if not any? turtles [ stop ]       ;;  si ya no queda nada por quemarse

  if inclinacion > 30 [              ;; como la inclinación del terreno es
                                     ;; importante, pero utilizando el modelo
                                     ;; no se muestra diferencia entre unas
                                     ;; pendientes y otras, se incluye una
                                     ;; condición especial
    ask turtles
      [
        set color red
        ask neighbors4 with [pcolor = green]
         [ ignite ]
        ;; el objetivo es incendiar el bosque en vertical, ya que hay pendiente pronunciada
        let nearby-patches patches with [pycor >= (pycor - 4) and pycor <= (pycor + 4) and distance myself <= 4]
        ask nearby-patches with [pcolor = green]
          [ ignite ]
        die
        ]
  ]

  if tipo-de-vegetacion = "hierba" [
     ;; Según los modelos de Rothermel, si la superficie en la que se propaga
     ;; el incendio son praderas con hierba, el fuego se extiende de forma rápida.
     ;; Se calcula la tasa de propagación
    let R rothermel-model cantidad-de-vegetacion 1
     velocidad-del-viento inclinacion humedad area-superficial-volumen

    ifelse velocidad-del-viento < 30 [   ;; si es un viento relativamente suave
      ask turtles
     [
        if R > 25 [
        set color red
        ask neighbors with [pcolor = green]
         [ ignite ]
        die
        ]

        if R > 10 [
        set color red
        ask neighbors4 with [pcolor = green]
         [ ignite ]
        die
        ]

        if R > 0 [
          set color red
          ask patch-here [
            if [pcolor] of patch-at 0 1 = green [ask patch-at 0 1 [ignite]]
            if [pcolor] of patch-at 0 -1 = green [ask patch-at 0 -1 [ignite]]
          ]
          die

        ]

       ]


    ]
    ;; Si son vientos de más de 30 mhp, lo cual empeora la propagación
   [
   ask turtles
     [
        set color red
        let nearby-patches patch-set patches with [distance myself <= 2]   ;; conjunto de casillas a menos de 2 casillas de distancia
        ask nearby-patches with [pcolor = green]
          [ ignite ]
        die
        ]
  ]

 ]


  if tipo-de-vegetacion = "matorral" [
     let R rothermel-model cantidad-de-vegetacion 5
     velocidad-del-viento inclinacion humedad area-superficial-volumen

    ask turtles [
      ifelse velocidad-del-viento < 30 [
      if humedad > 70 [                   ;; hay un modelo de Rothermel en el que el peligro está en la
                                          ;; alta humedad en zonas de matorral
          set color red
          let nearby-patches patch-set patches with [distance myself <= 3]
          ask nearby-patches with [pcolor = green]
            [ ignite ]
          die

      ]
      ifelse R < 7 [
          set color red
          ask neighbors4 with [pcolor = green]
            [ ignite ]
          die
      ]
      [
        set color red
        ask neighbors with [pcolor = green]
            [ ignite ]
          die

      ]
    ]
    [
        set color red
        let nearby-patches patch-set patches with [distance myself <= 2]
        ask nearby-patches with [pcolor = green]
          [ ignite ]
        die
        ]
    ]



    ]




  if tipo-de-vegetacion = "arbol" [
     let R rothermel-model cantidad-de-vegetacion 15
     velocidad-del-viento inclinacion humedad area-superficial-volumen

    ifelse velocidad-del-viento < 30 [     ;; los fuegos de copa son los más peligrosos, por eso
                                           ;; los métodos de propagación ocupan más casillas

    ask turtles
     [
       ifelse R < 7 [
          set color red
          ask neighbors with [pcolor = green]
            [ ignite ]
          die
      ]
      [
        set color red
        let nearby-patches patch-set patches with [distance myself <= 3]   ;; conjunto de parches a menos de 2 parches de distancia
        ask nearby-patches with [pcolor = green]
          [ ignite ]
          die

      ]
       ]
    ]
   [
   ask turtles
     [
        set color red
        let nearby-patches patch-set patches with [distance myself <= 4]   ;; conjunto de parches a menos de 4 parches de distancia
        ask nearby-patches with [pcolor = green]
          [ ignite ]
        die
        ]
  ]
  ]




  tick
  change-patches
  change-turtles

end

to change-patches
  ask patches [
    if pcolor = black [set pcolor black]
    if pcolor = red [set pcolor orange]
    if pcolor = orange [set pcolor black]
  ]

end

to change-turtles
    ask turtles  [
    if color = red [
      set color orange
      ask patch-here [ set pcolor orange ]

  ]
    if color = orange [
      set color black
      ask patch-here [ set pcolor black ]

  ]]
end




;; Se crean las tortugas que incendian el bosque
to ignite
  sprout 1
    [ set color red
      ask patch-here [ set pcolor orange]
     ]
  set burned-trees burned-trees + 1
end



;; Modelo de Rothermel, obtenido de A MATHEMATICAL MODEL FOR PREDICTING FIRE SPREAD IN WILDLAND FUELS
to-report rothermel-model [fuel-load fuel-depth wind-speed slope fuel-moisture fuel-sav]
    ;; Variables del modelo junto a otros parametros que se necesitan y que han sido
    ;; estudiados y tabulados previamente
    let wo dividir fuel-load 100000
    let fueld fuel-depth
    let wv wind-speed * 88
    let fpsa fuel-sav ;
    let mf fuel-moisture ; Fuel particle moisture content
    let h 8000 ; Fuel particle low heat content
    let pp 32. ; Ovendry particle density
    let mc 0.0555 ; Fuel particle mineral content
    let emc 0.010 ; Fuel Particle effective mineral content
    let mois-ext 0.12 ; Moisture content of extinction or 0.3 if dead

    ;; Calcular la arcotangente de la pendiente
    let slope-rad (to-rad slope)
    let tan-slope tan slope-rad

    ;; Betas
    let beta-op 3.348 * fpsa ^ (-0.8189) ; Optimum packing ratio
    let od-bd dividir wo fueld ; Ovendry bulk density
    let beta dividir od-bd pp  ;Packing ratio
    let beta-rel dividir beta beta-op

    ;; Reaction Intensity
    let a (1 / (4.774 * potencia fpsa (-1) - 7.27))
    let wn wo / (1 - mc) ; Net fuel loading
    let t-max fpsa ^ 1.5 * (495.0 + 0.0594 * fpsa ^ 1.5) ^ (-1.0) ; Maximum reaction velocity
    let t t-max * beta / beta-op ^ a * exp(a * (1 - beta / beta-op)) ; Optimum reaction velocity
    let nm 1. - 2.59 * (mf / mois-ext) + 5.11 * mf / mois-ext ^ 2. - 3.52 * mf / mois-ext ^ 3. ; Moisture damping coeff.
    ; mineral damping
    let ns 0.174 * emc ^ (-0.19) ; Mineral damping coefficient
    let ri t * wn * h * nm * ns

    let PFR (potencia (192 + 0.2595 * fpsa) -1) * exp ((0.792 + 0.681 * sqrt fpsa) * (Beta + 0.1)) ; Propogating flux ratio
                                                                                                  ;; Coeficiente de viento
    let B 0.02526 * potencia fpsa 0.54
    let C 7.47 * exp (-0.1333 * potencia fpsa 0.55)
    let F  -0.715 * exp (-3.59 * 10 ^(-4) * fpsa)

    let WC (-(C) * (wv ^ B)) * potencia (beta / beta-op) F ; Coeficiente de viento
                                                       ;; WC = WC * 0.74
                                                       ;; Coeficiente de pendiente
    let SC 5.275 * potencia Beta (-0.3) * potencia tan-slope 2


    let EHN exp(-138 / fpsa) ; Effective Heating Number = f(surface are volume ratio)
    let QIG 250 + 1116 * mf ; Heat of preignition= f(moisture content)
    ; rate of spread (ft per minute)
    ; RI = BTU/ft^2
    let numerator (RI * PFR * (1 + WC + SC))
    let denominator (od-bd * EHN * QIG)
    let R numerator / denominator

    report R

end

;; Funciones auxiliares
to-report dividir [num1 num2]
  report num1 / num2
end

to-report potencia [base exponente]
  report base ^ exponente
end


to-report to-rad [angulo]
  report angulo * (pi / 180)
end
@#$#@#$#@
GRAPHICS-WINDOW
210
10
868
669
-1
-1
13.0
1
10
1
1
1
0
0
0
1
0
49
0
49
0
0
1
ticks
30.0

BUTTON
25
47
88
80
setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
99
47
162
80
go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
14
179
186
212
cantidad-de-vegetacion
cantidad-de-vegetacion
0
100
44.0
1
1
NIL
HORIZONTAL

SLIDER
14
221
186
254
velocidad-del-viento
velocidad-del-viento
0
75
25.0
1
1
NIL
HORIZONTAL

SLIDER
14
266
186
299
humedad
humedad
0
100
20.0
1
1
NIL
HORIZONTAL

SLIDER
14
311
186
344
inclinacion
inclinacion
0
50
18.0
1
1
NIL
HORIZONTAL

MONITOR
927
65
1121
110
Porcentaje de vegetación quemada
(burned-trees / initial-trees)\n* 100
2
1
11

MONITOR
927
120
1121
165
Horas desde el inicio del incendio
ticks
17
1
11

SLIDER
13
358
187
391
area-superficial-volumen
area-superficial-volumen
200
5000
4996.0
1
1
NIL
HORIZONTAL

CHOOSER
26
96
164
141
tipo-de-vegetacion
tipo-de-vegetacion
"hierba" "matorral" "arbol"
0

TEXTBOX
925
210
1133
366
Este modelo se basa en el modelo de fuego de Rothermel, en el que se calcula una tasa de propagación en función de la cantidad de vegetación de un área, el tipo o altura, la velocidad del viento, la inclinación del terreno y el volumen de material por unidad de área. Puede seleccionarlos y observar cómo afecta a la propagación del fuego.
10
0.0
1

@#$#@#$#@
## WHAT IS IT?

El modelo de propagación de fuegos en entornos forestales que se presenta se basa en el propuesto por Richard Rothermel en 1970, que sigue siendo utilizado para planificar y gestionar la actuación contra incendios forestales. El modelo Rothermel es un modelo matemático que se utiliza para predecir la propagación del fuego y se basa en la idea de que el fuego se propaga a través de la quema de los combustibles en la superficie del terreno. Tiene en cuenta factores como la topografía del terreno, la velocidad y dirección del viento, la humedad y la densidad de los combustibles para estimar la velocidad y la dirección de la propagación del fuego. Es ampliamente utilizado en la planificación y gestión de incendios forestales en todo el mundo. 


## HOW IT WORKS

En el modelo, unas tortugas toman el papel de las llamas que extienden el fuego en un incendio forestal. Se calcula una constante R en función de los parámetros que escoja el usuario, que determinará el comportamiento de las tortugas. R es la tasa de propagación de Rothermel, también conocida como la tasa de propagación de fuego, y mide la velocidad a la que un fuego se extiende a través de un combustible.


Al inicio, deben elegirse los parámetros utilizando los deslizadores. Al elegir la cantidad de vegetación, se iniciará la cuadrícula con tantas casillas en verde como porcentaje de ocupación se haya tomado. Una tortuga (primera llama) se colocará de forma aleatoria en una de estas casillas verdes, preparada para iniciar el incendio. Dependiendo de los parámetros escogidos y el cálculo de R, tendrá lugar una propagación del fuego u otra. El incendio termina cuando no quedan más casillas verdes por quemar. 

En los contadores del lateral se observa el porcentaje de vegetación que ha ardido y las horas (ticks) que han pasado desde el inicio del incendio.


## HOW TO USE IT

Iniciar en setup una vez escogidos los parámetros. Posteriormente, iniciar la animación con go.

## THINGS TO NOTICE

Se observa que, cuando las condiciones del incendio no son demasiado extremas y existen algunos huecos entre plantas, este se detiene solo sin quemar demasiada vegetación. Esto prueba la importancia que tienen los cortafuegos en nuestros bosques.

Se ha agregado una condición especial para la pendiente, ya que es un factor de vital importancia en el desarrollo de un incendio, pero al modificar el valor de esta en la función principal del modelo, no se observaba ningún cambio importante, por lo que he decidido añadirla de manera separada.

## THINGS TO TRY

Observar el comportamiento distinto en hierbas, matorrales y árboles.

## EXTENDING THE MODEL

Esta es la implementación que se me ha ocurrido a mí, ya que en A MATHEMATICAL MODEL FOR PREDICTING FIRE SPREAD IN WILDLAND FUELS no hay demasiada información sobre la relación entre R y la magnitud del incendio, simplemente se menciona que a mayor tasa de propagación, mayor peligro para el bosque. Los distintos niveles los he tenido que escoger yo en función de modelos descriptivos también propuestos por Rothermel. Se sugiere que estos niveles se expresen de manera más exhaustiva.


## RELATED MODELS

Modelo de fuego de la biblioteca de modelos de NetLogo.

## CREDITS AND REFERENCES

Richard C Rothermel. A mathematical model for predicting fire spread in wildland
fuels. Research Paper INT-115, USDA Forest Service, Intermountain Forest and Range
Experiment Station, 1972.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
0
@#$#@#$#@
