#let report_template(
  title: "",
  course: "",
  report_type: "",
  footer_text: "",
  instructor: "",
  students: (),
  date: "",
  body
) = [
  #set text(font: "Times New Roman", size: 12pt, lang: "vi")

  #set page(
    paper: "a4",
    margin: 1in,
    numbering: "1",
    number-align: right,
    background: context if (counter(page).get().first() < 1) {
      rect(
        width: 90%,
        height: 92%,
        stroke: 5pt + black,
        inset: 1%,
        rect(
          width: 100%,
          height: 100.5%,
          stroke: 2pt + black,
          inset: 10pt
        )
      )
    },
    header: context {
      if counter(page).get().first() >= 1 [
        #set text(size: 10pt)
        #set par(first-line-indent: 0pt)

        #grid(
          columns: (auto, 1fr),
          align: (left + bottom, right + bottom),

          grid(
            columns: (auto, auto),
            gutter: 5pt,
            align: left + horizon,

            image("picture/logo.png", height: 2em),

            stack(
              dir: ttb,
              spacing: 5pt,
              text(size: 6.5pt, fill: rgb("#127ec3"))[ĐẠI HỌC QUỐC GIA THÀNH PHỐ HỒ CHÍ MINH],
              text(size: 10pt, fill: rgb("#022c87"), weight: "bold")[TRƯỜNG ĐẠI HỌC BÁCH KHOA]
            )
          ),

          pad(bottom: 2pt)[
            #text(size: 11pt)[Khoa Khoa Học và Kỹ Thuật Máy Tính]
          ]
        )
        #v(-6pt)
        #line(length: 100%, stroke: 0.7pt)
      ]
    },
    footer: context {
      if counter(page).get().first() >= 1 [
        #set text(size: 11pt)
        #line(length: 100%)
        #v(-4pt)
        #grid(
          columns: (2fr, 1fr),
          align: (left, right),
          [#footer_text],
          [Trang #counter(page).display("1/1", both: true)],
        )
      ]
    }
  )

  #set par(
    justify: true,
    leading: 1.0em,
    spacing: 0.75em,
    first-line-indent: 1em,
  )

  #show heading: it => {
    text(size: 13pt, it)
    if (it.body != [MỤC LỤC] and it.body != [DANH MỤC HÌNH ẢNH] and it.body != [DANH MỤC BẢNG BIỂU]) {
      ""
      context v(-par.spacing - measure("").height)
    }
  }

  #show list: it => {
    it
    ""
    context v(-par.spacing - measure("").height)
  }

  #show raw.where(block: false): box.with(
    fill: luma(240),
    inset: (x: 3pt, y: 0pt),
    outset: (y: 3pt),
    radius: 2pt,
  )
  #show raw.where(block: true): block.with(
    fill: luma(240),
    inset: 10pt,
    radius: 4pt,
  )

  #set heading(
    numbering: (..nums) => {
      let vals = nums.pos()
      if vals.len() == 1 {
        "CHƯƠNG " + str(vals.first()) + "."
      } else {
        numbering("1.1.", ..nums)
      }
    },
    supplement: [Chương]
  )
  #show heading.where(level: 1): set align(center)
  #show heading: set block(above: 0.85em, below: 0.75em)

  #counter(page).update(n => n - 1)
  #set page(numbering: none)
  #show figure: set block(breakable: true)

  // TRANG BÌA
  #align(center)[
    #text(15pt, weight: "bold")[
      ĐẠI HỌC QUỐC GIA THÀNH PHỐ HỒ CHÍ MINH \
      TRƯỜNG ĐẠI HỌC BÁCH KHOA \
      KHOA KHOA HỌC VÀ KỸ THUẬT MÁY TÍNH
    ]

    #image("picture/logo.png", width: 38%)

    #text(17pt, weight: "bold")[#course]

    #text(17pt, weight: "bold")[#report_type]

    #text(18pt, weight: "bold", fill: rgb("#022c87"))[#title]
  ]
  \
  #align(center)[
    #set text(size: 14pt)
    #table(
      stroke: none,
      columns: (2),
      align: left,
      [*GVHD: *], [#instructor],
    )
  ]

  #align(center, text(14pt, weight: "bold", [---o0o---]))

  #align(center)[
    #set text(size: 13pt)
    #table(
      stroke: none,
      columns: (3),
      align: left,
      [*Thành viên nhóm*], [], [],
      ..students.map(s => ([], s.at(0), s.at(1))).flatten()
    )
  ]
  #v(1fr)

  #align(center, text(14pt, [#date]))
  #pagebreak(weak: true)

  // BẢNG PHÂN CÔNG VÀ ĐÁNH GIÁ ĐÓNG GÓP
  #align(center)[
    #text(15pt, weight: "bold")[BẢNG ĐÁNH GIÁ ĐÓNG GÓP CỦA THÀNH VIÊN]
  ]
  #v(1em)

  #align(center)[
    #set text(size: 11.5pt)
    #table(
      columns: (auto, 2.8fr, 1.5fr, 1.3fr),
      align: (center + horizon, left + horizon, center + horizon, center + horizon),
      inset: 8pt,
      fill: (x, y) => if y == 0 { rgb("#e8f0fe") } else if calc.even(y) { rgb("#f8f9fa") } else { none },
      stroke: 0.5pt + luma(180),
      table.header(
        [*STT*], [*Họ và tên*], [*MSSV*] , [*Đóng góp*]
      ),
      ..students.enumerate().map(((idx, s)) => (
        str(idx + 1),
        s.at(0),
        s.at(1),
        if s.len() >= 3 { s.at(2) } else { "100%" }
      )).flatten()
    )
  ]
  #pagebreak(weak: true)

  // MỤC LỤC, DANH MỤC HÌNH ẢNH, DANH MỤC BẢNG BIỂU
  #set page(numbering: "1")
  #show outline.entry: it => {
    if it.level == 1 {
      text(weight: "bold", it)
    } else {
      text(weight: "regular", it)
    }
  }

  #outline(
    title: "MỤC LỤC",
    depth: 3,
    indent: 1.5em
  )
  #pagebreak(weak: true)

  #outline(
    title: "DANH MỤC HÌNH ẢNH",
    target: figure.where(kind: image),
  )
  #v(1.2em)
  #outline(
    title: "DANH MỤC BẢNG BIỂU",
    target: figure.where(kind: table),
  )
  #pagebreak(weak: true)

  #body
]


#show: report_template.with(
  title: [CLASS SCHEDULING USING GENETIC ALGORITHM ],
  course: [Nhập môn Trí tuệ Nhân tạo (CO3061)],
  report_type: [HOMEWORK 3],
  footer_text: [ Class Scheduling using Genetic Algorithm (CO3061)],
  instructor: [TS. NGUYỄN QUỐC MINH],

  students: (
    ("Nguyễn Ngọc Minh Hiền", "2352339", "100%" ),
    ("Lưu Ngọc Huyền", "2352418", "100%" ),
    ("Trương Quang Khải", "2352542", "100%" ),
     
    ("Hồ Phúc Khang", "2352468", "100%" ),
    ("Vũ Đức Thao", "2634004", "100%" ),
  ),

  date: [TP. HỒ CHÍ MINH, 11/2026],
)

#include "pages/chapter_1.typ"
#pagebreak()

#include "pages/chapter_2.typ"
#pagebreak()

#include "pages/chapter_3.typ"
#pagebreak()

#include "pages/chapter_4.typ"
#pagebreak()

#include "pages/chapter_5.typ"
#pagebreak()

#include "pages/chapter_6.typ"
#pagebreak()

#include "pages/chapter_7.typ"
#pagebreak()

#bibliography("ref.bib",
  title: "TÀI LIỆU THAM KHẢO",
  full: true,
  style: "association-for-computing-machinery"
)
#pagebreak()

#include "pages/appendix.typ"
