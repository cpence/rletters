## Mostrar red de términos

#### Esta tarea de análisis muestra la red de términos asociados a una palabra importante.

El objetivo de esta tarea es la evaluación de la red de términos que se encuentran alrededor de una palabra importante de interés en todo el conjunto de datos. El análisis sigue, más o menos, la metodología descrita en [este artículo.](http://noduslabs.com/research/pathways-meaning-circulation-text-network-analysis/) Comenzamos con la creación de una versión del texto podada, sin palabras no significativas, sólo con palabras. (Por ahora, esta opción sólo está disponible en inglés y, por lo tanto, este algoritmo unicamente funcionará con **textos en inglés.**)

A continuación hacemos una red mediante la creación de nodos conectados por (i) cada par de palabras que incluya la palabra importantes y (ii) cada par de nodos dentro de la *zona de cinco palabras* que contienen la palabra importante. Esto subraya su estrecha conectividad al mismo tiempo que muestra una estructura más grande.

La gráfica está dibujada de forma que adecua el tamaño del nodo en base a su importancia (es decir, el número de nodos conectados a ese nodo). La distancia entre nodos, así cómo el grosor de las líneas que los conectan, se escala según el número de veces que la conexión aparece en el conjunto de datos (conexiones gruesas y cortas indican enlaces fuertes). Como se ha mencionado, la red se dibuja usando una versión podada del texto. Mantener el puntero del ratón sobre un nodo de la gráfica mostrará el tema, así cómo todas las formas de la palabra que se encuentren en el conjunto de datos.

Esta tarea puede responder a una variedad de interesantes preguntas relacionadas con el significado de una palabra en concreto dentro de un conjunto de datos dado:

>¿Qué palabra aparece a menudo cerca de un concepto importante?
>
>Es más, ¿qué palabras aparecen normalmente cerca de *esas* palabras en este contexto en concreto?