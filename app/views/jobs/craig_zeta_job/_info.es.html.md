## Diferenciar dos conjuntos de datos

#### Esta tarea de análisis puede hacerle saber qué hace a dos artículos diferentes el uno del otro mediante el algoritmo «Zeta».

El algoritmo aquí implementado es Zeta, originalmente descrito [por John F. Burrows en 2007](10.1093/llc/fqi067) y ampliado [por Hugh Craig](https://en.wikipedia.org/w/index.php?title=Special%3ABookSources&isbn=9780521516235), así como implementado por [David L. Hoover.](https://files.nyu.edu/dh3/public/UsingtheCraigZetaSpreadsheet.html) Este algoritmo toma dos conjuntos de datos como entradas (las llama A y B) y da dos listas de palabras. Cada lista es un conjunto de palabras —que no son particularmente comunes ni tampoco raras— que probablemente cataloguen a un texto como perteneciente al conjunto A o al conjunto B, respectivamente. Esto es, si «Alemania» es una palabra Zeta para el conjunto A, entonces la aparición de «Alemania» en un texto hace que pertenezca con mayor probabilidad al conjunto A que al conjunto B.

Este algoritmo puede emplearse para responder al siguiente tipo de preguntas:

> ¿Qué términos son habituales en este conjunto pero no en otro? *(entrada: dos conjuntos de datos, un conjunto de interés y otro conjunto con el resto del corpus)*
> 
> ¿Qué términos hacen un hilo argumental de un discurso diferente de otro? *(entrada: dos conjuntos de datos, cada uno para cada hilo argumental de discurso)*
>
> ¿Qué conceptos han estado y dejado de estar en una disciplina a lo largo del tiempo? *(entrada: un conjunto de datos de trabajos antiguos y un conjunto de datos de trabajos recientes)*