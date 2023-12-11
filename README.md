# 영수증 다오 ReadME

## 목차
1. [APP 소개](#app-소개)
2. [버전 업데이트](#버전-업데이트)
3. [실행 화면](#실행-화면)
4. [타임라인](#타임라인)
5. [기술적 도전](#기술적-도전)
6. [트러블 슈팅 및 고민](#트러블-슈팅-및-고민)
7. [출시를 해보며 느낀 점](#출시를-해보며-느낀-점)

<br></br>
## APP 소개

자신이 사용한 영수증을 등록, 수정, 삭제, 즐겨찾기 할 수 있으며 월에 따른 목록을 볼 수 있습니다.

### App Idea 구상 계기
1. 백화점 POS 시스템 개발 운영업무를 하면서 영수증 분실 시 반품을 못하는 이유가 영수증 자체의 의미가 있기 때문이 아니라 영수증에 기재되는 거래 번호, 포스 번호, 날짜 등 종합적으로 매출 데이터베이스에서 찾아야 하는 필수적인 내용들을 모르기 때문에 반품이 불가능하다는 것을 알았습니다.
2. 대학병원 환자의 경우 보관 및 처리해야하는 영수증이 매우 많아 관리가 용이한 APP이 필요하다고 생각하였습니다.
3. 앱스토어에 기존에 존재하는 영수증 관리 앱들은 가계부와 결합되어있거나 회사에서 사용하는 용도였기 때문에 단순하며 심플한 영수증 관리 앱이 없다고 생각하였습니다.



### App Store Link
[영수증 다오 App Store](https://apps.apple.com/kr/app/%EC%98%81%EC%88%98%EC%A6%9D-%EB%8B%A4%EC%98%A4/id6449433216)

### App 지원 URL
[영수증 다오 지원 URL](https://pakhyo.notion.site/76d4525ba02a4b0fb10f18cfbf1db9a1)

<br></br>
## 버전 업데이트
### 1.0.3 (2023.05.30)
**오류 수정**
- 목록 화면에서 뒤로가다가 다시 돌아올 경우 NavagationBar가 사라지는 현상 수정
    -  Navagation Bar isHidden이 true로 변경되는 문제

**기능 변경**
- 영수증 사진을 등록하지 않았을 경우, 이미지 공유 버튼이 비활성화 되게끔 구현

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


### 1.2.0 (2023.06.12)
**기능 추가**
- 영수증에 관한 내용(상호명, 내역, 메모)을 기반으로 검색 기능 추가

**기능 개선**
- 선택한 사진 허용 권한에서도 OCR 기능 사용할 수 있도록 기능 개선

**코드 개선**
- ComposeView에서 Camera, Album에 Access하는 코드를 프로토콜로 분리하여 재사용성 향상
- RxSwift에서 제공하는 `withUnretained()`를 사용하여 약한 참조처리

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

<br></br>
## 실행 화면

|메인|등록 및 편집|목록|
|:---:|:--:|:--:|
|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/f950795a-4a68-4ad3-a180-a773b33b1c92">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/b2cace25-eeb8-4fd0-bb48-d5b4ef2500a4">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/71275434-a754-4836-bdc0-fe51a7d6b503" >|

|즐겨찾기|상세|
|:---:|:--:|
|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/53b81b18-e3fa-4461-b58c-c07036162ead">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/71275434-a754-4836-bdc0-fe51a7d6b503">|

<br></br>
## 타임라인

<details>
<summary> 
펼쳐보기
</summary>

### 1️⃣ feature 1
1. 기본 Model 구현
2. CoreData 관련 코드 구현
### 2️⃣ feature 2
1. Main View 구현 (홈화면)
2. SceneCoordinator 구현
### 3️⃣ feature 3
1. List View 구현
    - Cell 구현
2. Register View 구현
    - Cell 구현
### 4️⃣ feature 4
1. Favorite 구현 (즐겨찾기)
2. Detail View 구현
3. Cameara, PHPicker 수정 구현
### ▶️ 이후
1. App Icon
2. 앨범 선택적 접근 권한일 경우 선택한 이미지 보여주는 View 별도 구현
3. Vision Kit을 사용한 OCR 기능 추가
4. SearchBar를 사용한 검색 기능 추가

</details>


<br></br>
## 기술적 도전

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
    
</details>




<br></br>
## 트러블 슈팅 및 고민

### 🔥 Animation 효과를 줄 수 있는 RxDataSource

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
    
### 🔥 일 별로 Section을 생성하여 표현
    
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



### 🔥 목록화면에서 Receipt Data를 선택한 Month에 따라 가져와야 하는 문제
    
<details>
<summary> 
펼쳐보기
</summary>
    
기존의 ViewModel의 `receiptList`는 `store.fetch()`를 반환하였었습니다.
하지만 Month가 바뀔 때마다 새로운 DataList를 반환해야하기 때문에 ViewModel의 `currentDateRelay`를 만든 후, 해당 `Relay`에 새로운 이벤트가 전달될때, `DataList`도 바뀐 후에, 반환되어 `View`에 보여지게끔 구현하였습니다.

</details>


### 🧐 영수증 관련 정보를 등록할 때 ViewModel과 양방향 바인딩의 필요성에 대한 고민
<details>
<summary> 
펼쳐보기
</summary>

`ViewModel`에 있는 Data를 View의 UI에 바인딩 시키는 것은 맞지만, Data를 변경한 후, 저장기능을 구현할 때, 
수 많은 파라메터를 ViewModel에 전달해서 저장을 시키는 방법과 양방향 바인딩을 통한 UI의 Data들과 `ViewModel`의 속성을 동기화한 후 파라메터 없이 저장시키는 방법 중 고민을 하였습니다.
결론적으로 양방향 바인딩을 사용하였습니다. 
`View`와 `ViewModel`을 양방향 바인딩을 한다면, 입력과 동시에 ViewModel에 동기화가 이루어져 저장하는 로직이 간결해진다고 생각했습니다.
하지만, 데이터의 흐름과 코드의 복잡도가 높아진다는 생각이 들었습니다.

</details>


### 🔥 Cell 제일 앞에 Cell을 누르면 사진을 추가해야 하는 로직
    
<details>
<summary> 
펼쳐보기
</summary>

등록한 Image들을 `CollectionView`에서 표현하고자 하였고, 첫번째 Cell을 터치할 경우 ImagePicker로 이동하게 끔 구현하였습니다. 
첫번째 이미지를 지속적으로 표시해줘야 했기 때문에 `FirstCell()` 메서드를 호출하고 저장했을 경우 첫번째 인덱스의 Image를 Remove 한 후, 저장하였습니다.
    
</details>

### 🔥 Cell 삭제 동작 전달 방법
<details>
<summary> 
펼쳐보기
</summary>
    
등록한 Image를 수정할 때, 혹은 등록할 때 있어서 추가 뿐만 아니라 삭제 기능도 있어야 한다고 생각했습니다.
삭제 버튼을 이미지의 오른쪽 상단에 위치 시킨 후, Delegate Pattern을 이용하여 삭제 Action을 구현하였습니다.
이미지 삭제 시, `ViewModel`에게 선택한 `indexPath`를 전달하여 삭제하였습니다.
    
</details>


### 🔥 앨범 사진 선택적 사용에 대한 처리 방법
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
