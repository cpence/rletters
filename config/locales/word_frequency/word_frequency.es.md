## Generar la tabla de frecuencia de palabras

#### Esta tarea de análisis genera una tabla detallada de información sobre la frecuencia de palabras

Esta tarea brinda un gráfico sobre la frecuencia de palabras muy detallado y personalizable de diferentes formas. Puede eligir cualquiera de los siguientes métodos para seleccionar un conjunto de palabras en el que esté interesado:

* Analizar palabras sueltas o frases de más de una palabra (n-gramas)
* Escoger las N palabras más frecuentes (o n-gramas)  del conjunto de datos
* Para palabras sueltas:
    * Escoger una lista explícita de palabras
    * Eliminar de la lista las palabras más habituales en diferentes idiomas
    * Eliminar de la lista cualquier palabra que aparezca en una lista explícita dada
* Para n-gramas:
    * Incluir únicamente n-gramas con determinadas palabras
    * Excluir cualquier n-grama con determinadas palabras

Puede escoger dividir el texto en segmentos, requisito habitual para otros tipos de algoritmos de análisis. Puede crear los segmentos bien estableciendo un número de palabras o bien estableciendo el número de bloques que le gustaría tener en el resultado final. Estos bloques pueden generarse en cada artículo de revista o en varias listas de artículos de revistas (esto es, segmentados una vez concatenados los artículos en un gran texto).

Se mostrarán diferentes resultados. En cada bloque de texto segmentado, recibirá las siguientes estadísticas para cada palabra (o n-grama):

* Cuántas veces apareció esa palabra en un bloque
* El recuento absoluto dividido por el número de palabras de cada bloque (es decir, la fracción del bloque que constituye esta palabra)
*[La TF/IDF (Frecuencia de términos/Frecuencia inversa de documentos )](https://es.wikipedia.org/wiki/Tf-idf) del término en el conjunto de datos
* La TF/IDF de este término en el corpus como una unidad (no disponible para n-gramas)

También puede ver el número de tipos y tokens para cada segmento. Y, para el conjunto de datos completos, verá las siguientes estadísiticas para cada palabra:

* Cuántas veces aparece esa palabra en todo el conjunto de datos
* Ese recuento absoluto dividido por el número de palabras en el conjunto de datos (es decir, la fracción del conjunto de datos que esta palabra constituye)
* La DF (frecuencia de documentos) de este término en el corpus completo (es decir, el número de documentos en los que aparece el término en toda la base de datos. No disponible para n-gramas)
* TF/IDF of this term within the entire corpus (no disponible para n-grams)

Además de proporcionar las entradas sin formato para una amplia variedad de algoritmos de análisis textual que el usuario puede ejecutar por su cuenta, estos datos pueden responder rápidamente a diversas e interesantes preguntas:

> ¿Cuán a menudo se utilizan ciertas palabras en un conjunto de datos dato? *(Entrada: un campo de interés, buscando la proporción para el término en cuestión)*
>
¿Utiliza el conjunto de la literatura unas palabras más que el resto de la cultura en general? *(Entrada: un campo de interés, comparando la proporción para los términos en cuestión a la proporción cuestionada desde [Google Ngram Viewer](https://books.google.com/ngrams))*
>
> ¿Cuáles son las palabras «interesantes» o «inusuales» en este conjunto de datos en concreto con respecto al resto del corpus? *(Entrada: un campo de interés, buscando la proporción de la TF/IDF de términos en todo en conjunto de datos contra el corpus —valores grandes indican que el término es «inusual» para el corpus en general, pero aparece frecuentemente en el conjunto de datos)*