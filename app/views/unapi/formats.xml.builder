xml.instruct!
opts = {}
opts[:id] = params[:id] if params[:id].present?
xml.formats(opts) {
  RLetters::Documents::Serializers::Base.available.each do |k|
    klass = RLetters::Documents::Serializers::Base.for(k)
    xml.format(name: k.to_s,
               type: Mime::Type.lookup_by_extension(k).to_s,
               docs: klass.url)
  end
}
