# -*- encoding : utf-8 -*-

FactoryGirl.define do

  factory :document do
    transient do
      uid 'doi:10.1234/this.is.a.doi'
      doi nil
      license nil
      license_url nil
      authors nil
      title nil
      journal nil
      year nil
      volume nil
      number nil
      pages nil
      fulltext nil
      term_vectors nil
    end

    factory :full_document do
      transient do
        uid 'doi:10.1234/5678'
        doi '10.1234/5678'
        license 'Public domain'
        data_source 'Test fixture'
        license_url 'https://creativecommons.org/publicdomain/zero/1.0/'
        authors 'A. One, B. Two'
        title 'Test Title'
        journal 'Journal'
        year '2010'
        volume '10'
        number '20'
        pages '100-200'
        fulltext <<-eos
          Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do
          eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim
          ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut
          aliquip ex ea commodo consequat. Duis aute irure dolor in
          reprehenderit in voluptate velit esse cillum dolore eu fugiat
          nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt
          in culpa qui officia deserunt mollit anim id est laborum.

          Pellentesque habitant morbi tristique senectus et netus et malesuada
          fames ac turpis egestas. Aliquam erat volutpat. In facilisis bibendum
          tincidunt. Cras in ex sit amet dui pulvinar blandit aliquam vitae
          risus. Curabitur commodo nibh ex, in tincidunt diam porta at. Proin
          euismod at leo a faucibus. Quisque sagittis facilisis malesuada.
          Quisque efficitur quis lacus eget finibus. Nulla facilisi.
          Suspendisse pharetra turpis vitae odio placerat consequat. Nunc at
          pulvinar risus, at rutrum sem. Ut fringilla mauris quam. Aenean
          mollis congue arcu, sodales lacinia risus facilisis in.

          Cum sociis natoque penatibus et magnis dis parturient montes,
          nascetur ridiculus mus. Suspendisse auctor lectus sit amet egestas
          consequat. Ut nec varius magna. Vivamus non feugiat ligula, eu
          vulputate lorem. Duis nulla nisi, fringilla a sollicitudin sed,
          fringilla eu urna. Fusce porta nulla libero, volutpat pharetra
          sapien gravida sed. Proin sed dictum sapien, in feugiat ex.
          Suspendisse vel massa congue, congue orci ut, luctus leo. Cras eu
          dapibus arcu, quis sollicitudin dolor. Cras vitae volutpat quam, in
          vulputate ante. Nulla pharetra diam convallis molestie venenatis. Sed
          luctus condimentum erat sed fringilla.

          Nunc efficitur diam et tortor fermentum, quis tincidunt ante
          vehicula. Duis sagittis eros egestas interdum pulvinar. Praesent ut
          massa a purus iaculis lacinia non sed nisi. Suspendisse ac sapien eu
          mi egestas auctor sed eu nunc. Morbi viverra sem vestibulum, eleifend
          odio ac, rutrum dolor. Nulla eu sapien a tellus porttitor vestibulum.
          Phasellus tincidunt sapien molestie ligula lobortis maximus. Nullam
          sed maximus diam. Proin viverra sem vel enim dignissim rutrum. Nullam
          nec suscipit nibh, et feugiat mauris. Phasellus bibendum ut erat id
          pretium.

          Mauris et maximus nunc. Nullam justo est, laoreet nec orci et,
          lobortis congue velit. Sed arcu neque, mattis vel tincidunt sit amet,
          semper at sapien. Sed ornare metus magna, nec scelerisque leo varius
          sed. In sem eros, pretium ac viverra a, ultrices et augue.
          Pellentesque purus nunc, rutrum ac mi vitae, porttitor pretium ex.
          Nam mi erat, ultrices sed metus non, maximus molestie dui.
          Suspendisse elit purus, sollicitudin eget turpis a, sollicitudin
          ornare nulla. Sed dapibus mauris suscipit velit mattis, in finibus
          turpis mattis. Curabitur nisl purus, dictum a arcu nec, vehicula
          ultrices leo. Maecenas elit tellus, mollis a urna in, rhoncus
          hendrerit nunc. Curabitur bibendum velit vitae ante lobortis
          sagittis. Aliquam tincidunt elit vel nulla convallis cursus.
        eos

        term_vectors {
          {
            a: { tf: 8, positions: [113, 188, 264, 293, 368, 398, 416, 426], df: 1.0 },
            ac: { tf: 5, positions: [79, 272, 287, 366, 376], df: 1.0 },
            ad: { tf: 1, positions: [21], df: 1.0 },
            adipiscing: { tf: 1, positions: [6], df: 1.0 },
            aenean: { tf: 1, positions: [145], df: 1.0 },
            aliqua: { tf: 1, positions: [18], df: 1.0 },
            aliquam: { tf: 3, positions: [82, 97, 439], df: 1.0 },
            aliquip: { tf: 1, positions: [31], df: 1.0 },
            amet: { tf: 4, positions: [4, 93, 170, 349], df: 1.0 },
            anim: { tf: 1, positions: [65], df: 1.0 },
            ante: { tf: 3, positions: [232, 253, 436], df: 1.0 },
            arcu: { tf: 4, positions: [148, 222, 343, 417], df: 1.0 },
            at: { tf: 5, positions: [108, 111, 135, 138, 351], df: 1.0 },
            auctor: { tf: 2, positions: [167, 277], df: 1.0 },
            augue: { tf: 1, positions: [371], df: 1.0 },
            aute: { tf: 1, positions: [37], df: 1.0 },
            bibendum: { tf: 3, positions: [87, 323, 433], df: 1.0 },
            blandit: { tf: 1, positions: [96], df: 1.0 },
            cillum: { tf: 1, positions: [46], df: 1.0 },
            commodo: { tf: 2, positions: [34, 101], df: 1.0 },
            condimentum: { tf: 1, positions: [241], df: 1.0 },
            congue: { tf: 4, positions: [147, 213, 214, 340], df: 1.0 },
            consectetur: { tf: 1, positions: [5], df: 1.0 },
            consequat: { tf: 3, positions: [35, 133, 172], df: 1.0 },
            convallis: { tf: 2, positions: [236, 444], df: 1.0 },
            cras: { tf: 3, positions: [89, 219, 226], df: 1.0 },
            culpa: { tf: 1, positions: [60], df: 1.0 },
            cum: { tf: 1, positions: [154], df: 1.0 },
            cupidatat: { tf: 1, positions: [55], df: 1.0 },
            curabitur: { tf: 3, positions: [100, 412, 432], df: 1.0 },
            cursus: { tf: 1, positions: [445], df: 1.0 },
            dapibus: { tf: 2, positions: [221, 403], df: 1.0 },
            deserunt: { tf: 1, positions: [63], df: 1.0 },
            diam: { tf: 4, positions: [106, 235, 247, 307], df: 1.0 },
            dictum: { tf: 2, positions: [205, 415], df: 1.0 },
            dignissim: { tf: 1, positions: [313], df: 1.0 },
            dis: { tf: 1, positions: [160], df: 1.0 },
            do: { tf: 1, positions: [9], df: 1.0 },
            dolor: { tf: 4, positions: [2, 39, 225, 289], df: 1.0 },
            dolore: { tf: 2, positions: [16, 47], df: 1.0 },
            dui: { tf: 2, positions: [94, 391], df: 1.0 },
            duis: { tf: 3, positions: [36, 184, 255], df: 1.0 },
            ea: { tf: 1, positions: [33], df: 1.0 },
            efficitur: { tf: 2, positions: [120, 246], df: 1.0 },
            egestas: { tf: 4, positions: [81, 171, 258, 276], df: 1.0 },
            eget: { tf: 2, positions: [123, 396], df: 1.0 },
            eiusmod: { tf: 1, positions: [10], df: 1.0 },
            eleifend: { tf: 1, positions: [285], df: 1.0 },
            elit: { tf: 4, positions: [7, 393, 423, 441], df: 1.0 },
            enim: { tf: 2, positions: [20, 312], df: 1.0 },
            erat: { tf: 4, positions: [83, 242, 325, 384], df: 1.0 },
            eros: { tf: 2, positions: [257, 364], df: 1.0 },
            esse: { tf: 1, positions: [45], df: 1.0 },
            est: { tf: 2, positions: [67, 334], df: 1.0 },
            et: { tf: 9, positions: [15, 74, 76, 158, 248, 319, 329, 338, 370], df: 1.0 },
            eu: { tf: 7, positions: [48, 181, 192, 220, 274, 279, 291], df: 1.0 },
            euismod: { tf: 1, positions: [110], df: 1.0 },
            ex: { tf: 5, positions: [32, 91, 103, 209, 381], df: 1.0 },
            excepteur: { tf: 1, positions: [52], df: 1.0 },
            exercitation: { tf: 1, positions: [26], df: 1.0 },
            facilisi: { tf: 1, positions: [126], df: 1.0 },
            facilisis: { tf: 3, positions: [86, 117, 152], df: 1.0 },
            fames: { tf: 1, positions: [78], df: 1.0 },
            faucibus: { tf: 1, positions: [114], df: 1.0 },
            fermentum: { tf: 1, positions: [250], df: 1.0 },
            feugiat: { tf: 3, positions: [179, 208, 320], df: 1.0 },
            finibus: { tf: 2, positions: [124, 409], df: 1.0 },
            fringilla: { tf: 4, positions: [142, 187, 191, 244], df: 1.0 },
            fugiat: { tf: 1, positions: [49], df: 1.0 },
            fusce: { tf: 1, positions: [194], df: 1.0 },
            gravida: { tf: 1, positions: [201], df: 1.0 },
            habitant: { tf: 1, positions: [70], df: 1.0 },
            hendrerit: { tf: 1, positions: [430], df: 1.0 },
            iaculis: { tf: 1, positions: [266], df: 1.0 },
            id: { tf: 2, positions: [66, 326], df: 1.0 },
            in: { tf: 12, positions: [40, 42, 59, 85, 90, 104, 153, 207, 230, 362, 408, 428], df: 1.0 },
            incididunt: { tf: 1, positions: [12], df: 1.0 },
            interdum: { tf: 1, positions: [259], df: 1.0 },
            ipsum: { tf: 1, positions: [1], df: 1.0 },
            irure: { tf: 1, positions: [38], df: 1.0 },
            justo: { tf: 1, positions: [333], df: 1.0 },
            labore: { tf: 1, positions: [14], df: 1.0 },
            laboris: { tf: 1, positions: [28], df: 1.0 },
            laborum: { tf: 1, positions: [68], df: 1.0 },
            lacinia: { tf: 2, positions: [150, 267], df: 1.0 },
            lacus: { tf: 1, positions: [122], df: 1.0 },
            laoreet: { tf: 1, positions: [335], df: 1.0 },
            lectus: { tf: 1, positions: [168], df: 1.0 },
            leo: { tf: 4, positions: [112, 218, 359, 421], df: 1.0 },
            libero: { tf: 1, positions: [197], df: 1.0 },
            ligula: { tf: 2, positions: [180, 301], df: 1.0 },
            lobortis: { tf: 3, positions: [302, 339, 437], df: 1.0 },
            lorem: { tf: 2, positions: [0, 183], df: 1.0 },
            luctus: { tf: 2, positions: [217, 240], df: 1.0 },
            maecenas: { tf: 1, positions: [422], df: 1.0 },
            magna: { tf: 3, positions: [17, 176, 356], df: 1.0 },
            magnis: { tf: 1, positions: [159], df: 1.0 },
            malesuada: { tf: 2, positions: [77, 118], df: 1.0 },
            massa: { tf: 2, positions: [212, 263], df: 1.0 },
            mattis: { tf: 3, positions: [345, 407, 411], df: 1.0 },
            mauris: { tf: 4, positions: [143, 321, 328, 404], df: 1.0 },
            maximus: { tf: 4, positions: [303, 306, 330, 389], df: 1.0 },
            metus: { tf: 2, positions: [355, 387], df: 1.0 },
            mi: { tf: 3, positions: [275, 377, 383], df: 1.0 },
            minim: { tf: 1, positions: [22], df: 1.0 },
            molestie: { tf: 3, positions: [237, 300, 390], df: 1.0 },
            mollis: { tf: 2, positions: [146, 425], df: 1.0 },
            mollit: { tf: 1, positions: [64], df: 1.0 },
            montes: { tf: 1, positions: [162], df: 1.0 },
            morbi: { tf: 2, positions: [71, 281], df: 1.0 },
            mus: { tf: 1, positions: [165], df: 1.0 },
            nam: { tf: 1, positions: [382], df: 1.0 },
            nascetur: { tf: 1, positions: [163], df: 1.0 },
            natoque: { tf: 1, positions: [156], df: 1.0 },
            nec: { tf: 5, positions: [174, 316, 336, 357, 418], df: 1.0 },
            neque: { tf: 1, positions: [344], df: 1.0 },
            netus: { tf: 1, positions: [75], df: 1.0 },
            nibh: { tf: 2, positions: [102, 318], df: 1.0 },
            nisi: { tf: 3, positions: [29, 186, 270], df: 1.0 },
            nisl: { tf: 1, positions: [413], df: 1.0 },
            non: { tf: 4, positions: [56, 178, 268, 388], df: 1.0 },
            nostrud: { tf: 1, positions: [25], df: 1.0 },
            nulla: { tf: 8, positions: [50, 125, 185, 196, 233, 290, 401, 443], df: 1.0 },
            nullam: { tf: 3, positions: [304, 315, 332], df: 1.0 },
            nunc: { tf: 6, positions: [134, 245, 280, 331, 374, 431], df: 1.0 },
            occaecat: { tf: 1, positions: [54], df: 1.0 },
            odio: { tf: 2, positions: [131, 286], df: 1.0 },
            officia: { tf: 1, positions: [62], df: 1.0 },
            orci: { tf: 2, positions: [215, 337], df: 1.0 },
            ornare: { tf: 2, positions: [354, 400], df: 1.0 },
            pariatur: { tf: 1, positions: [51], df: 1.0 },
            parturient: { tf: 1, positions: [161], df: 1.0 },
            pellentesque: { tf: 2, positions: [69, 372], df: 1.0 },
            penatibus: { tf: 1, positions: [157], df: 1.0 },
            pharetra: { tf: 3, positions: [128, 199, 234], df: 1.0 },
            phasellus: { tf: 2, positions: [297, 322], df: 1.0 },
            placerat: { tf: 1, positions: [132], df: 1.0 },
            porta: { tf: 2, positions: [107, 195], df: 1.0 },
            porttitor: { tf: 2, positions: [295, 379], df: 1.0 },
            praesent: { tf: 1, positions: [261], df: 1.0 },
            pretium: { tf: 3, positions: [327, 365, 380], df: 1.0 },
            proident: { tf: 1, positions: [57], df: 1.0 },
            proin: { tf: 3, positions: [109, 203, 308], df: 1.0 },
            pulvinar: { tf: 3, positions: [95, 136, 260], df: 1.0 },
            purus: { tf: 4, positions: [265, 373, 394, 414], df: 1.0 },
            quam: { tf: 2, positions: [144, 229], df: 1.0 },
            qui: { tf: 1, positions: [61], df: 1.0 },
            quis: { tf: 4, positions: [24, 121, 223, 251], df: 1.0 },
            quisque: { tf: 2, positions: [115, 119], df: 1.0 },
            reprehenderit: { tf: 1, positions: [41], df: 1.0 },
            rhoncus: { tf: 1, positions: [429], df: 1.0 },
            ridiculus: { tf: 1, positions: [164], df: 1.0 },
            risus: { tf: 3, positions: [99, 137, 151], df: 1.0 },
            rutrum: { tf: 4, positions: [139, 288, 314, 375], df: 1.0 },
            sagittis: { tf: 3, positions: [116, 256, 438], df: 1.0 },
            sapien: { tf: 6, positions: [200, 206, 273, 292, 299, 352], df: 1.0 },
            scelerisque: { tf: 1, positions: [358], df: 1.0 },
            sed: { tf: 14, positions: [8, 190, 202, 204, 239, 243, 269, 278, 305, 342, 353, 361, 386, 402], df: 1.0 },
            sem: { tf: 4, positions: [140, 283, 310, 363], df: 1.0 },
            semper: { tf: 1, positions: [350], df: 1.0 },
            senectus: { tf: 1, positions: [73], df: 1.0 },
            sint: { tf: 1, positions: [53], df: 1.0 },
            sit: { tf: 4, positions: [3, 92, 169, 348], df: 1.0 },
            sociis: { tf: 1, positions: [155], df: 1.0 },
            sodales: { tf: 1, positions: [149], df: 1.0 },
            sollicitudin: { tf: 4, positions: [189, 224, 395, 399], df: 1.0 },
            sunt: { tf: 1, positions: [58], df: 1.0 },
            suscipit: { tf: 2, positions: [317, 405], df: 1.0 },
            suspendisse: { tf: 5, positions: [127, 166, 210, 271, 392], df: 1.0 },
            tellus: { tf: 2, positions: [294, 424], df: 1.0 },
            tempor: { tf: 1, positions: [11], df: 1.0 },
            tincidunt: { tf: 6, positions: [88, 105, 252, 298, 347, 440], df: 1.0 },
            tortor: { tf: 1, positions: [249], df: 1.0 },
            tristique: { tf: 1, positions: [72], df: 1.0 },
            turpis: { tf: 4, positions: [80, 129, 397, 410], df: 1.0 },
            ullamco: { tf: 1, positions: [27], df: 1.0 },
            ultrices: { tf: 3, positions: [369, 385, 420], df: 1.0 },
            urna: { tf: 2, positions: [193, 427], df: 1.0 },
            ut: { tf: 8, positions: [13, 19, 30, 141, 173, 216, 262, 324], df: 1.0 },
            varius: { tf: 2, positions: [175, 360], df: 1.0 },
            vehicula: { tf: 2, positions: [254, 419], df: 1.0 },
            vel: { tf: 4, positions: [211, 311, 346, 442], df: 1.0 },
            velit: { tf: 4, positions: [44, 341, 406, 434], df: 1.0 },
            venenatis: { tf: 1, positions: [238], df: 1.0 },
            veniam: { tf: 1, positions: [23], df: 1.0 },
            vestibulum: { tf: 2, positions: [284, 296], df: 1.0 },
            vitae: { tf: 5, positions: [98, 130, 227, 378, 435], df: 1.0 },
            vivamus: { tf: 1, positions: [177], df: 1.0 },
            viverra: { tf: 3, positions: [282, 309, 367], df: 1.0 },
            voluptate: { tf: 1, positions: [43], df: 1.0 },
            volutpat: { tf: 3, positions: [84, 198, 228], df: 1.0 },
            vulputate: { tf: 2, positions: [182, 231], df: 1.0 }
          }
        }
      end
    end

    initialize_with do
      doc = Document.new(uid: uid, doi: doi, license: license,
                         license_url: license_url, authors: authors,
                         title: title, journal: journal, year: year,
                         volume: volume, number: number, pages: pages,
                         fulltext: fulltext)
      doc.term_vectors = term_vectors && term_vectors.with_indifferent_access
      doc
    end
  end

end
