# -*- encoding : utf-8 -*-

# If you get errors concerning the creation of the Java VM, then set these
# variables to the appropriate value to ensure that Java can be found
#ENV['JAVA_HOME'] = '/usr/lib/jvm/java-7-openjdk'
#ENV['LD_LIBRARY_PATH'] = "#{ENV['JAVA_HOME']}/jre/lib/amd64:#{ENV['JAVA_HOME']}/jre/lib/amd64/client"


# Initialze the Stanford NLP
StanfordCoreNLP.jar_path = Rails.root.join('vendor', 'nlp').to_s + File::SEPARATOR
StanfordCoreNLP.model_path = Rails.root.join('vendor', 'nlp').to_s + File::SEPARATOR
StanfordCoreNLP.log_file = Rails.root.join('log', 'stanford-nlp.log').to_s

# See if we have the JARs, and if not, disable the NLP-based jobs with a
# good old fashioned global variable
NER_CLASSIFIER_PATH = Rails.root.join('vendor', 'nlp', 'classifiers', 'all.3class.distsim.crf.ser.gz').to_s
NLP_ENABLED = File.exists?(NER_CLASSIFIER_PATH)

if NLP_ENABLED
  # Load the java classes now, on initialization
  StanfordCoreNLP.bind
end
