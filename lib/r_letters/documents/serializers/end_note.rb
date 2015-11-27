
module RLetters
  module Documents
    module Serializers
      # Convert a document to an EndNote record
      class EndNote < Base
        define_array(:endnote, 'EndNote',
                     'http://auditorymodels.org/jba/bibs/NetBib/Tools/bp-0.2.97/doc/endnote.html') do |doc|
          ret = "%0 Journal Article\n"
          doc.authors.each do |a|
            ret << "%A #{a.last}, #{a.first}"
            ret << " #{a.prefix}" if a.prefix
            ret << ", #{a.suffix}" if a.suffix
            ret << "\n"
          end
          ret << "%T #{doc.title}\n" if doc.title
          ret << "%D #{doc.year}\n" if doc.year
          ret << "%J #{doc.journal}\n" if doc.journal
          ret << "%V #{doc.volume}\n" if doc.volume
          ret << "%N #{doc.number}\n" if doc.number
          ret << "%P #{doc.pages}\n" if doc.pages
          ret << "%M #{doc.doi}\n" if doc.doi
          ret << "\n"
          ret
        end
      end
    end
  end
end
