# 다오 ReadME

## 목차
1. [APP 소개](#app-소개)
2. [버전 업데이트](#버전-업데이트)
3. [실행 화면](#실행-화면)
4. [기술적 도전 및 트러블 슈팅](#기술적-도전-및-트러블-슈팅)
5. [구현 사항](#구현-사항)
6. [출시를 해보며 느낀 점](#출시를-해보며-느낀-점)

<br></br>
## APP 소개

- 지출 내역을 등록 및 수정할 수 있으며, 리스트와 캘린더 형식을 통해 지출을 파악할 수 있습니다.
- 월별 분석을 통해 지출 내역을 전 월과 비교할 수 있으며, OCR 기능을 통해 영수증의 내용을 빠르게 작성할 수 있습니다.

### App Idea 구상 계기
1. 백화점 POS 시스템 개발 운영업무를 하면서 영수증 분실 시 반품을 못하는 이유가 영수증 자체의 의미가 있기 때문이 아니라 영수증에 기재되는 거래 번호, 포스 번호, 날짜 등 종합적으로 매출 데이터베이스에서 찾아야 하는 필수적인 내용들을 모르기 때문에 반품이 불가능하다는 것을 알았습니다.
2. 대학병원 환자의 경우 보관 및 처리해야하는 영수증이 매우 많아 관리가 용이한 APP이 필요하다고 생각하였습니다.
3. 영수증 관리 앱으로 출시 후, 지출 관리앱으로 확장한다면 보다 넓은 범위의 기능 제공이 가능하고, 기능 확장의 용이성이 높다고 생각하여 지출 관리 앱으로 통합 및 확장하게 되었습니다.


### App Store Link
[다오 App Store](https://apps.apple.com/kr/app/%EC%98%81%EC%88%98%EC%A6%9D-%EB%8B%A4%EC%98%A4/id6449433216)

### App 지원 URL
[다오 지원 URL](https://pakhyo.notion.site/76d4525ba02a4b0fb10f18cfbf1db9a1)

<br></br>
## 버전 업데이트

### 1.0.3 (2023.05.30)
**오류 수정**
- 목록 화면에서 뒤로가다가 다시 돌아올 경우 NavagationBar가 사라지는 현상 수정
    -  Navagation Bar isHidden이 true로 변경되는 문제

**기능 변경**
- 영수증 사진을 등록하지 않았을 경우, 이미지 공유 버튼이 비활성화 되게끔 구현
--------
### 1.1.0 (2023.06.05)
**기능 추가**
- 영수증 이미지를 등록한다면 첫번째 이미지에 대해서 OCR기능을 제공(iOS 16이상)
    - OCR기능은 날짜, 상호명, 가격, 현금/카드 선택에 적용

 **오류 수정**
 - iOS 14버전에서 영수증 등록화면에서 DatePicker Text가 보이지 않는 오류 수정

**코드 개선**
- ComposeViewModel과 ComposeView 바인딩되는 요소 변경
    - Receipt Data가 아닌 각 내부 요소들을 Relay로 가지고 있고 그것들을 View와 바인딩
    - 개선함으로서 하나의 TextFiedl가 변경될 때, 다른 TextField는 변경이 되지 않는다.
--------
### 1.2.0 (2023.06.12)
**기능 추가**
- 영수증에 관한 내용(상호명, 내역, 메모)을 기반으로 검색 기능 추가

**기능 개선**
- 선택한 사진 허용 권한에서도 OCR 기능 사용할 수 있도록 기능 개선

**코드 개선**
- ComposeView에서 Camera, Album에 Access하는 코드를 프로토콜로 분리하여 재사용성 향상
- RxSwift에서 제공하는 `withUnretained()`를 사용하여 약한 참조처리
--------
### 1.3.0 (2023.07.02)
**기능 추가**
- 영어, 일본어 지역화 구현
- 별도의 설정화면 구현
  - 달러, 엔화 선택
  - 메일 앱으로 이동 후 정해진 템플릿에 문의 내용을 작성할 수 있도록 구현
  - 앱스토어로 이동 후 앱에 대한 리뷰를 작성할 수 있는 기능 구현

**코드 개선**
- 메인화면에서 사용하는 Search에 대한 기능을 별도의 SearchScene과 SearchViewModel로 분리
  - 메인화면의 450줄 정도의 코드를 225 줄로 코드량을 감소시키고 기능에 대한 분리를 실천
 --------
### 1.4.0 (2023.11.01)
**기능 추가**

- Mantis 라이브러리 추가하여 이미지 편집 기능 추가
    - 이미지 편집 기능 요청 메일
        - <img width="755" alt="스크린샷 2023-11-07 오후 4 30 44" src="https://github.com/KyoPak/Receipt-DAO/assets/59204352/1c01d74a-3387-41e6-ae1c-e142015c1757">

- 가격 소수점 기입 가능하게 추가
  - CoreData Migration을 통해 기존의 Int형 Price를 String형 Price로 Sync 구현
  - 가격 소수점 기입 가능 요청 메일
      - <img width="1388" alt="스크린샷 2023-11-07 오후 4 32 14" src="https://github.com/KyoPak/Receipt-DAO/assets/59204352/07a70c1d-1f74-4d7b-ad94-780cdaaf7beb">

**기능 개선**
- UI 개선 : 기존 UI개선 및 라이트 모드, 다크 모드 분리
--------
### 2.0.0 (2023.12.23)
**기능 개선**
- 전체적인 UI 개편
    - 홈화면 개편(기존의 버튼 나열 식 홈화면 ➡️ 탭바)
    - 등록 화면, 상세화면 UI 개편

**기능 추가**
- Calendar 기능 추가
- 월 별 분석 기능 추가
- OCR 기능 개선

**코드 개선**
- 양방향 바인딩을 ReactorKit을 활용한 단방향 바인딩으로 구현
- Memory Leak 추적을 통해 사용자 디바이스 리소스 활용도 증대
- Reactor Test 작성
- 오류에 관련된 내용을 사용자에게 제공하기 위해 Alert 구현
- 앱의 갑작스러운 중단에 대한 추적을 위한 FireBase Crashlytics 추가
- 기존의 열거형 Coordinator 패턴 내부의 의존성 감소를 위해 Protocol 및 각 Class로 분리
--------
### 2.0.1 (2024.01.17)
**기능 개선**
- OCR Error 발생 시, 재시도 가능하도록 Error Handling 개선
- CoreData 비동기적으로 동작할 수 있도록 backGround Context 사용  

**코드 개선**
- Repository Pattern 도입
- Repository Test Code 작성
--------

<br></br>
## 실행 화면

<details>
<summary> 
펼쳐보기
</summary>

### 주요 기능 화면 

|목록|캘린더|캘린더리스트|
|:---:|:--:|:--:|
|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/8199fad5-5a87-44d0-8fd3-0652603a30f3">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/9af978b3-c8e6-4a53-b85f-b98825416296">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/0fcb0f7e-970f-4c5e-ad74-29551963bdaf" >|


|월별분석|등록|OCR|
|:---:|:--:|:--:|
|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/b869cab2-a09c-40f0-97ef-49338edfefc1">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/f5cd028d-4c2c-41da-8e96-ddfc8aae790b">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/d724e2c9-57ff-4afa-8a63-dc42ea2e81b8">|

|상세|즐겨찾기|설정|
|:---:|:--:|:--:|
|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/72ca7df6-ed64-4aed-a340-2f33a694b9a6">|<img width = "300px" img src = "https://github.com/KyoPak/Receipt-DAO/assets/59204352/8b856865-7433-4c9e-ac4d-6bd699e6e940">|<img width = "300px" img src = "https://github.com/KyoPak/Receipt-DAO/assets/59204352/4162fd30-7a60-4c74-b024-28f7af8b3ca9">

### 다크 모드 화면
    
|목록|캘린더|
|:---:|:--:|
|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/83fa32f6-d4e4-4977-aca4-db9825ded301">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/ab922c51-8605-4c06-8261-7790d99c5bfe">|

|캘린더리스트|상세|
|:--:|:--:|
|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/cbc24300-2075-401c-9c9e-32ba6b2f9067">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/4ff6e941-f8d5-44d5-9dff-1b9868a3ffe1">|
    

</details>

<br></br>
## 기술적 도전 및 트러블 슈팅

### ⚙️ Reactor Kit
<details>
<summary> 
펼쳐보기
</summary>
    
기존에는 View와 ViewModel간의 상태들과 바인딩을 할 경우, 양방향 바인딩을 사용하였습니다. 
양방향 바인딩을 하며, 각 요소의 하나하나의 변경에 대해 상태값들이 변경되고 즉각적인 동기화가 된다는 점이 편리하였습니다. 하지만, ComposeView의 가격 Text를 수정해야했을 때, 디버깅을 하는 과정에서 불편함을 경험하였으며,
ViewModel의 상태값이 많아질수록 관리하기가 어렵고 여러 메서드에서 로직을 구현해줘야했습니다.
    
때문에 타 프로젝트 "팬팔"에서 경험했던 단방향 바인딩을 적용하기로 결정하였으며, 단방향 바인딩을 프레임워크화한 ReactorKit을 사용해보기로 하였습니다.
또한, 오랜 기간에 걸쳐 꾸준히 앱을 유지보수하는 과정에 있어서 빠르게 코드를 다시 파악하기 좋기 때문에 도입을 결정하였습니다.
또한 Mutate에서 여러 Action에 대한 로직들을 세분화하고, Reduce에서 State값들을 처리하기 때문에 로직을 유지보수하기도 편리하다고 생각이 들었습니다.

</details>

### ⚙️ RxSwift
<details>
<summary> 
펼쳐보기
</summary>
    
왜 RxSwift를 사용했는가?
- 그동안 프로젝트를 하며 데이터 바인딩 부분을 클로져, 델리게이트, Observable로 해결을 했었습니다.
또한, 비동기 메서드인 경우 Completion Handler을 통해 데이터를 전달해줬었습니다.
RxSwift를 사용하여 가독성 높은 비동기 처리 메서드를 구현할 수 있기 때문에 사용하였으며, 값이나 상태의 변화에 따라 새로운 결과를 도출하는 코드를 쉽게 구현할 수 있기 때문에 사용하였습니다.

사용하면서 느낀점
- 처음에 러닝커브로 인해 사용에 익숙하지 않았지만 사용을 해보며 RxSwift의 문법을 알고 있다면 굉장히 가독성이 높아질 수 있다고 생각하였습니다.
하지만 많은 Operator 사용법이 숙지되어야 보다 짧고 함수형 프로그래밍이 결합된 RxSwift를 사용할 수 있다고 생각하였습니다.
    
</details>

### ⚙️ OCR
<details>
<summary> 
펼쳐보기
</summary>
    
왜 OCR 기능을 추가했는가?
- OCR을 추가한다면 잘못인식된 경우에 유저가 오히려 글자를 지우고 쓰는 경우가 많아 사용성이 떨어질 것이라고 생각했습니다.
- 하지만 OCR을 적용한 버전을 몇일 사용을 해보며 글자를 지우더라도 작성을 하지 않아도 되는 부분이 생기니 오히려 편리함을 느꼈고, 주변의 유저들도 OCR을 적용하는 편이 훨씬 편할 것 같다는 의견을 제시하여 반영하였습니다.

어떤 종류의 OCR이 있나?
- 네이버 클로버
    - 글자 인식 뿐만 아니라, 영수증에 대한 이미지 학습을 네이버에서 해놨기 때문에 원하는 요소들을 더 세부적으로 추출할 수 있습니다.
    - 300건까지 무료, 그 이후 영수증 인식 건당 100원이 부과됩니다.
- FireBase ML Kit
    - 구글에서 모바일 개발자에게 제공하는 머신러닝 기술을 제공하는 SDK입니다.
    - 글자 추출이 가능합니다.
- Apple Vision Kit
    - 애플에서 개발했으며 해당 프레임워크는 얼굴 및 얼굴 랜드마크 감지, 텍스트 감지, 바코드 인식, 이미지 등록 및 일반 기능 추적을 수행할 수 있습니다.
    - 무료이며 iOS 16 버전부터 한국어 지원을 합니다.

사용하면서 느낀점
- 생각보다 매우 인식률이 좋았습니다. 직접 촬영한 다양한 영수증을 입력할때 잘 추출이 되었습니다.
- 하지만 영수증마다 날짜를 표기하는 양식이 다르고, 상호명을 입력하는 방식과 위치가 달라 해당 요소들을 추출 정확도가 떨어졌습니다.
    하지만 가격, 현금/카드 표기는 영수증마다 통일된 특징을 가지고 있어 추출 정확도를 보다 올릴 수 있었습니다.
- 또한 iOS 16 부터 Vision Kit에서 한글을 지원하기 때문에 iOS 16 부터 해당기능을 사용할 수 있도록 구현하였습니다.
(iOS 16 아래 버전을 고려하여 인식을 직접 해보았으나 인식률이 너무 좋지 않았습니다.)

    
- 이후 영어,일본어로 구성되어있는 영수증도 OCR 기능을 제공하고 싶었기 때문에 로직으로 각 TextField에 대입하는 방식 이 아닌 ComposeView 내부 ImageCollectionCell 내부의 버튼으로 이미지 내부의 글자를 추출하여 보여주었습니다.

<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/d724e2c9-57ff-4afa-8a63-dc42ea2e81b8">
</details>

### 🔥 Memory Leak
<details>
<summary> 
펼쳐보기
</summary>

**문제**
Instruments의 Leaks와 Debug Memory Graph를 통해 메모리 누수를 탐지하였습니다.
ComposeView, SearchView, CalndarListView 등 Modal로 화면이 표시되고 내려가는 경우, 메모리에서 할당해제가 되지 않는 문제가 있었습니다.
    
**해결**
원인은 ViewController와 Reactor간의 바인딩과 Reactor 내부에서 Self 캡쳐로 인한 강한 참조가 발생하였기 때문이었습니다.
때문에 withUnRetained()와 클로저 내부 weak self 캡처리스트를 통해 불필요한 RC를 상승시키지 않음으로서 문제를 해결할 수 있었습니다.
    
</details>


### 🔥 CoreData의 비동기 동작

<details>
<summary> 
펼쳐보기
</summary>

**문제1**
기존의 CoreData의 CRUD 연산은 ViewContext(메인 큐)에서 실행되었으며, 연산 시간이 길어질 경우 UI가 멈추는 현상이 발생하였습니다.

**문제2**
CoreData의 Context를 NewBackgroundContext(글로벌 큐)로 변경하여 실행하였지만, 다른 스레드에서 동기적으로 동작하기 때문에 메인 큐의 블로킹 문제가 지속되었습니다.

**해결**
CoreData의 NewBackgroundContext의 로직은 비동기적 메서드인 perform을 사용하거나, CoreDataService 메서드를 호출할 경우 비동기적으로 호출해야한다는 것을 알았습니다.
perform 블록 내부에서 context의 CRUD연산 코드를 작성하여 비동기적으로 수행하도록 수정하였으며, 메인 큐가 블로킹되는 문제를 해결할 수 있었습니다.
</details>

### 🔥 CoreData Migration
<details>
<summary> 
펼쳐보기
</summary>

**문제1**
기존의 CoreDataModel의 Price는 Int 타입이었습니다. 하지만, 영어 지역화를 실행하였기 때문에 소수점이 기입되도록 수정해야했습니다. 
    
**문제2**
새로운 String 타입의 Price를 CoreData Model에 Migration하여 추가했지만, 기존의 Int형 타입의 Price를 삭제한다면 데이터 충돌이 발생하여 앱이 제대로 동작하지 않는 오류가 발생하였습니다.
    
**해결**
앱을 시작할 경우 기존의 Int형 Price에 데이터가 존재한다면 새롭게 추가한 String 타입의 Price로 동기화하는 로직을 추가하여 업데이트 시 발생하는 문제를 최소화하여 해결할 수 있었습니다.    
</details>

<br></br>

## 구현 사항

### Coordinator 패턴을 수정한 이유

<details>
<summary> 
펼쳐보기
</summary>
    
기존의 Coordinator 패턴은 열겨형 방식으로 구현되어있었습니다. 그렇기 때문에 화면을 이동하는 메서드, close메서드들을 공통으로 사용하기 때문에 여러 중복적인 코드를 구현하지 않아도 된다는 이점이 있었습니다.

하지만, 화면이 다양해지고 늘어남에 따라서 의존성 문제가 있을 것이라고 판단하였으며, 기존의 ViewModel에서 Coordinator 메서드를 호출하는 방식이 아닌 View에서 Coordinator을 가지게함으로서 각 Coordinator가 가지고 있던 의존성들을 다음 화면에 주입해주기 편해질 것이라고 생각하여 Protocol과 각 Scene에 해당하는 Coordinator을 별도로 구현하였습니다.

</details>

### Cell Reactor을 추가한 이유

<details>
<summary> 
펼쳐보기
</summary>
    
List와 Calendar 내부의 Cell들에서 Setting Tap에서의 Currency(화폐) 변경에 즉각적으로 동기화되어야 했습니다.
때문에 ListCell과 CalendarCell Reactor의 Transform 메서드 내부에서 UserDefault Service의 변경에 즉각적으로 대응할 수 있도록 구현하였습니다.
    
</details>

### Animation 효과를 줄 수 있는 RxDataSource

<details>
<summary> 
펼쳐보기
</summary>

기존의 `DiffableDataSource`처럼 Animation효과를 부여하기 위해 아래의 코드를 사용하였습니다.
기존의 `DiffableDataSource`처럼 `Hashable`를 채택해야했고, 추가적으로 `IdentifiableType`를 채택하여 구분자를 설정해줘야했습니다.
```swift
typealias ReceiptSectionModel = AnimatableSectionModel<String, Receipt>
typealias TableViewDataSource = RxTableViewSectionedAnimatedDataSource<ReceiptSectionModel>
```
따라서 영수증 목록과 즐겨찾기 목록에서 Cell의 추가, 편집, 삭제에 대해서 Animation을 부여할 수 있었습니다.
그리고 Animation이 불필요한 부분은 데이터와 `CollectionView.rx.item()`를 바인딩하여 쉽게 보여줄 수 있었습니다.

</details>
    
    
### 일 별로 Section을 생성하여 표현
    
<details>
<summary> 
펼쳐보기
</summary>
    
목록에 보여줘야 하는 Data들의 Section을 Data를 등록한 날짜로 부여하고 싶었습니다.
때문에 코어데이터 관련 파일의 `fetch()`메서드를 실행할 때 저장되어있는 데이터들을 `AnimatableSectionModel<String, Receipt>` 형태로 만들어야 했습니다.
아래의 Dictionary Grouping 을 사용하여 dictionary의 키값으로 날짜, 값으로 데이터들 가지는 Dictionary를 만들었습니다.
후에는 해당 Dictionary의 Data들을 map을 활용하여 원하는 형태의 Data 타입으로 생성하였습니다.
```swift
let dictionary = Dictionary(
        grouping: result,
        by: { DateFormatter.string(from: $0.receiptDate, dayFormat) }
    )
let section = dictionary.sorted { return $0.key > $1.key }
        .map { (key, value) in
            return ReceiptSectionModel(model: key, items: value)
        }
```
</details>



### 목록화면에서 Receipt Data를 선택한 Month에 따라 가져와야 하는 문제
    
<details>
<summary> 
펼쳐보기
</summary>
    
기존의 ViewModel의 `receiptList`는 `store.fetch()`를 반환하였었습니다.
하지만 Month가 바뀔 때마다 새로운 DataList를 반환해야하기 때문에 ViewModel의 `currentDateRelay`를 만든 후, 해당 `Relay`에 새로운 이벤트가 전달될때, `DataList`도 바뀐 후에, 반환되어 `View`에 보여지게끔 구현하였습니다.

</details>


### 영수증 관련 정보를 등록할 때 ViewModel과 양방향 바인딩의 필요성에 대한 고민
<details>
<summary> 
펼쳐보기
</summary>

`ViewModel`에 있는 Data를 View의 UI에 바인딩 시키는 것은 맞지만, Data를 변경한 후, 저장기능을 구현할 때, 
수 많은 파라메터를 ViewModel에 전달해서 저장을 시키는 방법과 양방향 바인딩을 통한 UI의 Data들과 `ViewModel`의 속성을 동기화한 후 파라메터 없이 저장시키는 방법 중 고민을 하였습니다.
결론적으로 양방향 바인딩을 사용하였습니다. 
`View`와 `ViewModel`을 양방향 바인딩을 한다면, 입력과 동시에 ViewModel에 동기화가 이루어져 저장하는 로직이 간결해진다고 생각했습니다.
하지만, 데이터의 흐름과 코드의 복잡도가 높아진다는 생각이 들었습니다.
    
가격 기입 포맷을 변경하는 과정에서 데이터 추적 과정이 쉽지않았고, 복잡하다고 생각이 들어 단방향 바인딩을 사용하는 ReactorKit을 도입하였습니다.

</details>

### 앨범 사진 선택적 사용에 대한 처리 방법
<details>
<summary> 
펼쳐보기
</summary>
    
앨범에 대한 권한을 유저가 전체허용일 경우는 문제가 되지 않았습니다. 
하지만 선택적 허용으로 했을 때, 유저가 허용한 이미지에 대해서만 접근을 해서 사진을 등록해야했습니다.
따라서 유저가 선택한 이미지만을 보여줄 수 있는 별도의 컬렉션 뷰를 만들었습니다.
또한 추가적으로 이미지를 불러올 수 있는 팝업이 앱을 구동하고 최초 1번만 발생하는 것을 알았고, 
유저에게 보다 선택적으로 추가적인 이미지를 사용할 수 있는 권한을 주기 위해 별도의 버튼을 생성하여 추가적으로 이미지를 불러올 수 있도록 구현하였습니다.
    
추가적인 선택을 누를 때, 기존의 허용한 사진을 보여주는 컬렉션 뷰 화면은 내려 간 후, 추가적인 이미지 허용 화면이 보여지게끔 로직을 세웠습니다.
그리고 기존의 시스템에서 제공하는 앱 구동 후 최초 1번 추가적인 이미지를 가져오는 팝업은 보이지 않게끔 처리하였습니다.
    
</details>
    
    
<br></br>
## 출시를 해보며 느낀 점

처음으로 앱 출시를 진행하면서, 순수한 구현능력 외에도 다양한 요소들이 중요하다는 것을 깨닫게 되었습니다.
먼저 앱을 출시할 때는 사용자에게 필요한 가치를 제공하는 것이 핵심이라는 점을 알 수 있었습니다. 
이를 위해 앱의 목적과 목표를 명확하게 설정하고, 이를 바탕으로 사용자의 요구를 세밀하게 분석하여 그에 맞는 기능을 구현해야 한다는 것을 깨달았습니다.
또한, 사용자 중심의 UI와 UX의 중요성을 몸소 느끼게 되었습니다. 배포 전에는 생각치 못했던 세부적인 UI와 UX에 대한 디테일한 부분을 고려하고 구현하는 과정을 통해 이를 체감하였습니다.
기능을 반복적으로 사용해보면서 사용자가 어떻게 사용할지를 생각하고 어떤점이 추가적으로 필요한지 생각하며 현재 달로 돌아가는 버튼, 키보드의 툴바 버튼, 선택적 허용 사진을 위한 뷰등을 추가적으로 고려하여 구현할 수 있었습니다.
직관적이고 시각적으로 좋은 디자인도 중요하지만, 사용자의 액션을 고려하고 유도하는 UI와 UX도 매우 중요하다는 것을 알 수 있었습니다.
