# -*- encoding : utf-8 -*-

def double_document_basic
  double(doi: '10.1234/5678',
         title: 'Test Title',
         authors: 'A. One, B. Two',
         author_list: ['A. One', 'B. Two'],
         formatted_author_list: [
           double(first: 'A.', last: 'One', prefix: nil, suffix: nil),
           double(first: 'B.', last: 'Two', prefix: nil, suffix: nil)
           ],
         journal: 'Journal',
         volume: '10',
         number: '20',
         year: '2010',
         pages: '100-200',
         start_page: '100',
         end_page: '200')
end
