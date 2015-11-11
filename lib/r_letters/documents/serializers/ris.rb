
module RLetters
  module Documents
    module Serializers
      # Convert a document to a RIS record
      class RIS < Base
        define_array('RefMan/RIS',
                     'http://www.refman.com/support/risformat_intro.asp') do |doc|
          ret  = "TY  - JOUR\n"
          doc.authors.each do |a|
            ret << 'AU  - '
            ret << "#{a.prefix} " if a.prefix
            ret << "#{a.last},#{a.first}"
            ret << ",#{a.suffix}" if a.suffix
            ret << "\n"
          end
          ret << "TI  - #{doc.title}\n" if doc.title
          ret << "PY  - #{doc.year}\n" if doc.year
          ret << "JO  - #{doc.journal}\n" if doc.journal
          ret << "VL  - #{doc.volume}\n" if doc.volume
          ret << "IS  - #{doc.number}\n" if doc.number
          ret << "SP  - #{doc.start_page}\n" if doc.start_page
          ret << "EP  - #{doc.end_page}\n" if doc.end_page
          ret << "ER  - \n"
          ret
        end
      end
    end
  end
end
