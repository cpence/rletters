## Analizar coocurrencias

#### Esta tarea de análisis crea una lista de pares de palabras distantes estadísticamente relevantes.

En el procesamiento del lenguaje natural, una [coocurrencia](https://es.wikipedia.org/wiki/Coocurrencia) es una asociación entre pares de palabras estadísticamente relevantes donde dichas palabras no tiene que aparecer forzosamente una al lado de la otra. Por ejemplo, los párrafos que a menudo mencionan a Naciones Unidas probablemente tambien mencionarán a la Asamblea General o al Consejo de Seguridad.

(Si desea determinar asociaciones estadísticamente relevantes entre palabras situadas cerca las unas de las otras, pruebe el análisis de colocaciones).

This task can use the following two different methods for determining significant cooccurrences:

* [Información mutua,](https://es.wikipedia.org/wiki/Informaci%C3%B3n_mutua) que mide el punto hasta el cual conocer la primera parte del par de palabras proporciona información sobre la segunda parte.
* [Prueba t de student con una cola,](https://en.wikipedia.org/wiki/Student's_t-test) que determina si hay o no un respaldo considerable para discernir si la hipótesis de que un par de palabras dado está correlacionado con la hipótesis nula de que las palabras están distribuidas de forma independiente.

El usuario puede cambiar los siguientes parámetros:

* El interés de la palabra: el análisis mostrará la relevancia para *todas* las coocurrencias con esta palabra.
* Cuántas coocurrencias mantener de las más relevantes.
* La ventana para la cual detectaremos coocurrencias. El algoritmo de coocurrencia busca correlaciones relevantes entre palabras que se dan a una distancia determinada. Para emular la coocurrencia de «nivel de frase», utilice una distancia de 5 palabras. Para una coocurrencia de «nivel de frase», pruebe con 20. Para una coocurrencia de «nivel de párrafo», utilice 200. La distancia máxima es el nivel de artículo; cambie el valor de la distacia a un número muy alto para buscar coocurrencias de nivel de artículo.

Una vez que se termine la tarea, se ofrece al usuario la descarga de las coocurrencias encontradas. Esta tarea puede responder a una variedad de preguntas interesantes.

> ¿A qué conceptos se recurre, a menudo juntos, en la literatura? *(Entrada: un campo de interés, seleccionar uno de los tres primeros métodos de análisis y luego buscar por conceptos de interés)*