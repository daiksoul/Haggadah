enum Book{
  gen(kor: "창세기",korAb: "창", engAb:"gen",newT: false,chapters: 50),
  exo(kor: "출애굽기",korAb: "출", engAb:"exo",newT: false,chapters: 40),
  lev(kor: "레위기",korAb: "레", engAb:"lev",newT: false,chapters: 27),
  num(kor: "민수기",korAb: "민", engAb:"num",newT: false,chapters: 36),
  deu(kor: "신명기",korAb: "신", engAb:"deu",newT: false,chapters: 34),
  jos(kor: "여호수아",korAb: "수", engAb:"jos",newT: false,chapters: 24),
  jdg(kor: "사사기",korAb: "삿", engAb:"jdg",newT: false,chapters: 21),
  rut(kor: "룻기",korAb: "룻", engAb:"rut",newT: false,chapters: 4),
  sa1(kor: "사무엘상",korAb: "삼상", engAb:"1sa",newT: false,chapters: 31),
  sa2(kor: "사무엘하",korAb: "삼하", engAb:"2sa",newT: false,chapters: 24),
  ki1(kor: "열왕기상",korAb: "왕상", engAb:"1ki",newT: false,chapters: 22),
  ki2(kor: "열왕기하",korAb: "왕하", engAb:"2ki",newT: false,chapters: 25),
  ch1(kor: "역대상",korAb: "대상", engAb:"1ch",newT: false,chapters: 29),
  ch2(kor: "역대하",korAb: "대하", engAb:"2ch",newT: false,chapters: 36),
  ezr(kor: "에스라",korAb: "스", engAb:"ezr",newT: false,chapters: 10),
  neh(kor: "느헤미야",korAb: "느", engAb:"neh",newT: false,chapters: 13),
  est(kor: "에스더",korAb: "에", engAb:"est",newT: false,chapters: 10),
  job(kor: "욥기",korAb: "욥", engAb:"job",newT: false,chapters: 42),
  psa(kor: "시편",korAb: "시", engAb:"psa",newT: false,chapters: 150),
  pro(kor: "잠언",korAb: "잠", engAb:"pro",newT: false,chapters: 31),
  ecc(kor: "전도서",korAb: "전", engAb:"ecc",newT: false,chapters: 12),
  sng(kor: "아가",korAb: "아", engAb:"sng",newT: false,chapters: 8),
  isa(kor: "이사야",korAb: "사", engAb:"isa",newT: false,chapters: 66),
  jer(kor: "예레미야",korAb: "렘", engAb:"jer",newT: false,chapters: 52),
  lam(kor: "예레미야애가",korAb: "애", engAb:"lam",newT: false,chapters: 5),
  ezk(kor: "에스겔",korAb: "겔", engAb:"ezk",newT: false,chapters: 48),
  dan(kor: "다니엘",korAb: "단", engAb:"dan",newT: false,chapters: 12),
  hos(kor: "호세아",korAb: "호", engAb:"hos",newT: false,chapters: 14),
  jol(kor: "요엘",korAb: "욜", engAb:"jol",newT: false,chapters: 3),
  amo(kor: "아모스",korAb: "암", engAb:"amo",newT: false,chapters: 9),
  oba(kor: "오바댜",korAb: "옵", engAb:"oba",newT: false,chapters: 1),
  jnh(kor: "요나",korAb: "욘", engAb:"jnh",newT: false,chapters: 4),
  mic(kor: "미가",korAb: "미", engAb:"mic",newT: false,chapters: 7),
  nam(kor: "나훔",korAb: "나", engAb:"nam",newT: false,chapters: 3),
  hab(kor: "하박국",korAb: "합", engAb:"hab",newT: false,chapters: 3),
  zep(kor: "스바냐",korAb: "습", engAb:"zep",newT: false,chapters: 3),
  hag(kor: "학개",korAb: "학", engAb:"hag",newT: false,chapters: 2),
  zec(kor: "스가랴",korAb: "슥", engAb:"zec",newT: false,chapters: 14),
  mal(kor: "말라기",korAb: "말", engAb:"mal",newT: false,chapters: 4),
  mat(kor: "마태복음",korAb: "마", engAb:"mat",newT:true,chapters: 28),
  mrk(kor: "마가복음",korAb: "막", engAb:"mrk",newT:true,chapters: 16),
  luk(kor: "누가복음",korAb: "눅", engAb:"luk",newT:true,chapters: 24),
  jhn(kor: "요한복음",korAb: "요", engAb:"jhn",newT:true,chapters: 21),
  act(kor: "사도행전",korAb: "행", engAb:"act",newT:true,chapters: 28),
  rom(kor: "로마서",korAb: "롬", engAb:"rom",newT:true,chapters: 16),
  co1(kor: "고린도전서",korAb: "고전", engAb:"1co",newT:true,chapters: 16),
  co2(kor: "고린도후서",korAb: "고후", engAb:"2co",newT:true,chapters: 13),
  gal(kor: "갈라디아서",korAb: "갈", engAb:"gal",newT:true,chapters: 6),
  eph(kor: "에베소서",korAb: "엡", engAb:"eph",newT:true,chapters: 6),
  php(kor: "빌립보서",korAb: "빌", engAb:"php",newT:true,chapters: 4),
  col(kor: "골로새서",korAb: "골", engAb:"col",newT:true,chapters: 4),
  th1(kor: "데살로니가전서",korAb: "살전", engAb:"1th",newT:true,chapters: 5),
  th2(kor: "데살로니가후서",korAb: "살후", engAb:"2th",newT:true,chapters: 3),
  ti1(kor: "디모데전서",korAb: "딤전", engAb:"1ti",newT:true,chapters: 6),
  ti2(kor: "디모데후서",korAb: "딤후", engAb:"2ti",newT:true,chapters: 4),
  tit(kor: "디도서",korAb: "딛", engAb:"tit",newT:true,chapters: 3),
  phm(kor: "빌레몬서",korAb: "몬", engAb:"phm",newT:true,chapters: 1),
  heb(kor: "히브리서",korAb: "히", engAb:"heb",newT:true,chapters: 13),
  jas(kor: "야고보서",korAb: "약", engAb:"jas",newT:true,chapters: 5),
  pe1(kor: "베드로전서",korAb: "벧전", engAb:"1pe",newT:true,chapters: 5),
  pe2(kor: "베드로후서",korAb: "벧후", engAb:"2pe",newT:true,chapters: 3),
  jn1(kor: "요한1서",korAb: "요일", engAb:"1jn",newT:true,chapters: 5),
  jn2(kor: "요한2서",korAb: "요이", engAb:"2jn",newT:true,chapters: 1),
  jn3(kor: "요한3서",korAb: "요삼", engAb:"3jn",newT:true,chapters: 1),
  jud(kor: "유다서",korAb: "유", engAb:"jud",newT:true,chapters: 1),
  rev(kor: "요한계시록",korAb: "계", engAb:"rev",newT:true,chapters: 22);

  const Book({
    required this.kor,
    required this.korAb,
    required this.engAb,
    required this.newT,
    required this.chapters
  });
  final String kor;
  final String korAb;
  final String engAb;
  final bool newT;
  final int chapters;
}

class BookNChap{
  BookNChap(this.book, this.chapter);

  final Book book;
  final int chapter;

  bool validate(){
    return chapter<=book.chapters;
  }
}