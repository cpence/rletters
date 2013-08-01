xml.instruct!
opts = {}
opts[:id] = params[:id] unless params[:id].blank?
xml.formats(opts) {
  Document.serializers.each do |k, v|
    xml.format(name: k.to_s, type: Mime::Type.lookup_by_extension(k.to_s).to_s, docs: v[:docs])
  end
}
