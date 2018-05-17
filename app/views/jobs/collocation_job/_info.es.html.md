## Analizar colocaciones

Esta tarea de análisis realiza una lista de pares de palabras cercanos y  estadísticamente relevantes.

En el procesamiento del lenguaje natural, una [colocación](http://es.wikipedia.org/wiki/Colocaci%C3%B3n) es una asociación estadísticamente relevante de un par de palabras que aprecen una tras otra. Por ejemplo, mientras que en español suena natural «impartir clases» y «asestar un golpe», no sucede así con «asestar clases» e «impartir un golpe».

(Si desea determinar asociaciones estadísticamente relevantes entre palabras alejadas entre sí, pruebe el análisis de coocurrencia).

This task can use the following four different methods for determining significant pairs of words:

* [Información mutua,](https://es.wikipedia.org/wiki/Informaci%C3%B3n_mutua) que mide el punto hasta el cual conocer la primera parte del par de palabras proporciona información sobre la segunda parte.
* [Prueba t de student con una cola,](https://en.wikipedia.org/wiki/Student's_t-test) que determina si hay o no un respaldo considerable para discernir si la hipótesis de que un par de palabras dado está correlacionado con la hipótesis nula de que las palabras están distribuidas de forma independiente.
* [Cociente del logaritmo de verosimilitud,](https://es.wikipedia.org/wiki/Funci%C3%B3n_de_verosimilitud) que compara la probabilidad de que dos palabras sean independientes con la de que sean dependientes.
* [Frecuencia, sesgada por partes del discurso,](http://nlp.stanford.edu/fsnlp/promo/colloc.pdf) que ordena bigramas y trigramas por su frecuencia bruta de aparición para después filtrarlos según la parte del discurso.  [Justeson y Katz](http://dx.doi.org/10.1017/S1351324900000048) propusieron un conjunto de filtros basados en el etiquetado gramatical que separan las colocaciones útiles e interesantes de las que implican palabras no significativas.  (El etiquetado gramatical los realiza un software llamado [Standford POS Tagger.](http://nlp.stanford.edu/software/tagger.shtml)) Los patrones de categorías gramaticales que se guardan son los siguientes:
    * Adjetivo Nombre
    * Nombre Nombre
    * Adjetivo Adjetivo Nombre
    * Adjetivo Nombre Nombre
    * Nombre Adjetivo Nombre
    * Nombre Nombre Nombre
    * Nombre Preposición Nombre

El usuario puede especificar cuántas preposiciones de las más relevantes conservar, las cuales podrá descargar si lo desea. Esta tarea puede responder a una variedad de preguntas interesantes:

> ¿A qué conceptos se recurre, a menudo juntos, en la literatura? *(Entrada: un campo de interés, seleccionar uno de los tres primeros métodos de análisis y luego buscar por conceptos de interés)*
>
> ¿Qué términos técnicos o frases se utilizan a menudo en una disciplina? *(Entrada: un campo de interés, seleccionar el método de análisis de categorías gramaticales)*