# 영수증다오 ReadME

## 목차
1. [APP 소개](#app-소개)
2. [실행 화면](#실행-화면)
3. [타임라인](#타임라인)
4. [기술적 도전](#기술적-도전)
5. [트러블 슈팅 및 고민](#트러블-슈팅-및-고민)

<br></br>
## APP 소개

자신이 사용한 영수증을 등록, 수정, 삭제, 즐겨찾기 할 수 있으며 월에 따른 목록을 볼 수 있습니다.

### App Idea 구상 계기
1. 물건을 반품하려고 했는데 앨범에 찍어놓은 영수증을 찾기 위해 많은 시간을 소요한 경험이 있습니다.
3. 대학병원 환자의 경우 보관 및 처리해야하는 영수증이 매우 많아 관리가 용이한 APP이 필요하다고 생각하였습니다.
4. 영수증 보관기능만을 위한 심플한 영수증 보관 APP이 없다고 생각하였습니다.
### App Store Link
[영수증 다오](https://apps.apple.com/kr/app/%EC%98%81%EC%88%98%EC%A6%9D-%EB%8B%A4%EC%98%A4/id6449433216)

<br></br>
## 실행 화면

|목록|등록|상세|
|:---:|:--:|:--:|
|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/65d3e999-0e23-4653-9c5c-b9838b7f8c5f">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/ca1ae433-4efc-45e1-be33-092c2b0c179d">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/b6dc9462-0492-43b5-9ddb-0df856b8c2f4" >|


|즐겨찾기|사진선택|
|:---:|:--:|
|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/9dd57c20-2b4d-4f0d-95c0-63d2401bd5f2">|<img width = "300px" img src= "https://github.com/KyoPak/Receipt-DAO/assets/59204352/1741a9e1-bb50-4182-8435-915d6dc9f9ee">|

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
 
<img width = "300px" img src = "https://github.com/KyoPak/Receipt-DAO/assets/59204352/1741a9e1-bb50-4182-8435-915d6dc9f9ee">

</details>

<br></br>
## 기술적 도전

### ⚙️ RxSwift
<details>
<summary> 
펼쳐보기
</summary>
    
왜 RxSwift를 사용했는가?
- 그동안 프로젝트를 하며 데이터 바인딩 부분을 클로져, 델리게이트로 해결을 했었습니다.
또한, 비동기 메서드인 경우 Completion Handler을 통해 데이터를 전달해줬었습니다.
RxSwift를 사용하여 가독성 높은 비동기 처리 메서드를 구현할 수 있기 때문에 사용하였습니다.
사용하면서 느낀점
- 처음에 러닝커브로 인해 사용에 익숙하지 않았지만 사용을 해보며 RxSwift의 문법을 알고 있다면 굉장히 가독성이 높아질 수 있다고 생각하였습니다.
하지만 많은 Operator 사용법이 숙지되어야 보다 짧고 함수형 프로그래밍이 결합된 RxSwift를 사용할 수 있다고 생각하였습니다.
    
</details>

<br></br>
## 트러블 슈팅 및 고민

### 🔥 출시 목적에 따른 UI, UX에 대한 고민

<details>
<summary> 
펼쳐보기
</summary>

백화점 POS 시스템 개발 운영업무를 해왔을 때, 영수증이 없을 때 반품을 못하는 이유가 영수증 자체의 의미가 있기 때문이 아니라 영수증에 기재되는 거래번호, 포스번호, 날짜 등 종합적으로 매출 데이터베이스에서 찾아야하는 필수적인 내용들을 모르기 때문에 반품이 불가능하다는 것을 알았습니다.
때문에 이러한 정보들을 사진으로 찍는 사람이 많을 것이라 생각하였고, 저 또한 보관해야하는 영수증은 사진을 찍어 보관하였었습니다.
하지만 막상 반품을 하려할 때, 앨범 내에서 여러 사진들에서 영수증 사진을 또 찾는 과정이 불필요하다고 생각하였기 때문에 해당 APP을 고안하게 되었습니다.
    
</details>


### 🔥 Animation 효과를 줄 수 있는 RxDataSource

<details>
<summary> 
펼쳐보기
</summary>

기존의 `DiffableDataSource`처럼 Animation효과를 부여하기 위해 아래의 코드를 사용하였습니다.
기존의 `DiffableDataSource`처럼 `Hashable`를 채택해야했고, 추가적으로 `IdentifiableType`를 채택하여 구분자를 설정해줘야했습니다.
```
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
```
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


### 🔥 영수증 관련 정보를 등록할 때 ViewModel과 양방향 바인딩의 필요성에 대한 고민
<details>
<summary> 
펼쳐보기
</summary>

`ViewModel`에 있는 Data를 View의 UI에 바인딩 시키는 것은 맞지만, Data를 변경한 후, 저장을 누를때 수많은 파라메터를 통해서 저장을 시키는 방법과 양방향 바인딩을 통한 UI의 Data들과 `ViewModel`의 속성을 바인딩한후 파라메터 없이 저장시키는 방법 중 고민을 하였습니다.
결론적으로 양방향 바인딩을 사용하였습니다. 
`View`와 `ViewModel`을 바인딩하는 코드가 길어지긴 했지만, 양방향 바인딩이 조금 더 Reactive한 프로그래밍이라고 생각되었습니다.

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
<img width = "300px" img src= "https://hackmd.io/_uploads/ByxsrjsS3.jpg">
    
</details>


### 🔥 앨범 사진 선택적 사용에 대한 처리 방법
<details>
<summary> 
펼쳐보기
</summary>
    
앨범에 대한 권한을 유저가 전체허용을 하였을때는 문제가 되지 않았습니다. 
하지만 선택적 허용으로 했을 때, 유저가 허용한 이미지에 대해서만 접근을 해서 사진을 등록해야했습니다.
따라서 아래와 같이 유저가 선택한 이미지만을 보여줄 수 있는 별도의 컬렉션 뷰를 만들었습니다.
또한 추가적으로 이미지를 불러올 수 있는 팝업이 앱을 구동하고 최초 1번만 발생하는 것을 알았고, 
유저에게 보다 선택적으로 추가적인 이미지를 사용할 수 있는 권한을 주기 위해 별도의 버튼을 생성하여 추가적으로 이미지를 불러올 수 있도록 구현하였습니다.
<img width = "300px" img src= "https://hackmd.io/_uploads/HysAzsoBh.jpg">
    
추가적인 선택을 누를 때, 기존의 허용한 사진을 보여주는 컬렉션 뷰 화면은 내려 간 후, 추가적인 이미지 허용 화면이 보여지게끔 로직을 세웠습니다.
그리고 기존의 시스템에서 제공하는 앱 구동 후 최초 1번 추가적인 이미지를 가져오는 팝업은 보이지 않게끔 처리하였습니다.
    
</details>
