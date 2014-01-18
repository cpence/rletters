# -*- encoding : utf-8 -*-

# The list of lemmatized words returned by the Stanford NLP lemmatizer for
# the document_fulltext document
def stanford_nlp_lemmatizer
  ["it", "be", "the", "best", "of", "time", ",", "it", "be", "the", "worst",
   "of", "time", ",", "it", "be", "the", "age", "of", "wisdom", ",", "it",
   "be", "the", "age", "of", "foolishness", ",", "it", "be", "the", "epoch",
   "of", "belief", ",", "it", "be", "the", "epoch", "of", "incredulity", ",",
   "it", "be", "the", "season", "of", "light", ",", "it", "be", "the",
   "season", "of", "darkness", ",", "it", "be", "the", "spring", "of", "hope",
   ",", "it", "be", "the", "winter", "of", "despair", ",", "we", "have",
   "everything", "before", "we", ",", "we", "have", "nothing", "before",
   "we", ",", "we", "be", "all", "go", "direct", "to", "Heaven", ",", "we",
   "be", "all", "go", "direct", "the", "other", "way", "--", "in", "short",
   ",", "the", "period", "be", "so", "far", "like", "the", "present",
   "period", ",", "that", "some", "of", "its", "noisiest", "authority",
   "insist", "on", "its", "be", "receive", ",", "for", "good", "or", "for",
   "evil", ",", "in", "the", "superlative", "degree", "of", "comparison",
   "only", "."]
end

# Create all the required stubs so that calls to the NLP lemmatizer will work
def stub_stanford_nlp_lemmatizer
  stub_const('NLP_ENABLED', true)

  pipeline = double('StanfordPipeline')
  allow(pipeline).to receive(:annotate).and_return(nil)
  $mock_core_pipeline = pipeline

  core = Module.new do
    def self.load(*args); $mock_core_pipeline; end
  end
  allow(core).to receive(:load).with(any_args()).and_return(pipeline)
  stub_const('StanfordCoreNLP', core)

  token_array = stanford_nlp_lemmatizer.map do |w|
    token_object = double('StanfordToken')
    allow(token_object).to receive(:get).with(any_args()).and_return(w)
    token_object
  end

  annotation = Class.new do
    def initialize(*args); end
  end
  allow_any_instance_of(annotation).to receive(:get).with(any_args()).and_return(token_array)
  stub_const('StanfordCoreNLP::Annotation', annotation)
end
