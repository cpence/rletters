# -*- encoding : utf-8 -*-

StanfordCoreNLP.jar_path = Rails.root.join('vendor', 'nlp')
StanfordCoreNLP.model_path = Rails.root.join('vendor', 'nlp')
StanfordCoreNLP.log_file = Rails.root.join('log', 'stanford-nlp.log')

# See if we have the JARs, and if not, disable the NLP-based jobs with a
# good old fashioned global variable
NLP_ENABLED = File.exists?(Rails.root.join('vendor', 'nlp', 'stanford-corenlp.jar'))
