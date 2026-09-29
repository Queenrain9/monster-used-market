# v0.2.19 — Dedicated Seller Chat

## Why

채팅을 상세 내부에 넣으면 아무리 말풍선을 그려도:

> 상품 상세의 정보 조회 위젯

처럼 느껴진다.

따라서 정보 획득 행동을 별도 화면으로 분리한다.

## Navigation Contract

```
detail --OpenSellerChatButton--> chat
chat --BackButton/BackToDetailButton--> detail
```

`current_stage="chat"`은 저장 가능하다.

## Detail Responsibility

상세는 다음만 책임진다.

- 판매글
- 직거래 정보
- 판매자 개요
- chat entry point
- compact memo summary
- trade plan
- price negotiation entry

질문 선택과 대화 thread는 소유하지 않는다.

## Chat Responsibility

SellerChatPanel은 다음을 책임진다.

- seller identity
- listing context
- persistent message thread
- four seller reply choices
- one self-research action
- remaining investigation opportunities

## Memo Summary

상세에서는 discovered_clues 전체를 길게 반복하지 않는다.

`거래 메모 N개`와 최근 최대 두 개만 보여준다.

전체 정보 획득 경험은 채팅 thread가 담당한다.

## Search Action

market 조사만 대화 선택지에서 분리한다.

판매자에게 메시지를 보내지 않고 note만 누적한다.

이 분리는 “괴물에게 질문한다”와 “내가 시장을 조사한다”를 플레이어 행동 수준에서 구분한다.
