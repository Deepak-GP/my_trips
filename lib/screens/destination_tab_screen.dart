
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:trips/models/destinationModel.dart';
import 'package:trips/models/photos_model.dart';

class DestinationTabScreen extends StatefulWidget {
  final Destination destination;

  DestinationTabScreen({@required this.destination});

  @override
  _DestinationTabScreenState createState() => _DestinationTabScreenState();
}

class _DestinationTabScreenState extends State<DestinationTabScreen> with TickerProviderStateMixin{
  TabController tabController;
  TabBar tabBarItem;

  _updateImagesList(List<dynamic> newImageList) async
  {
    for(var image in widget.destination.images)
    {
      newImageList.add(image);
    }

    var document = Firestore.instance.collection('Destinations').document(widget.destination.reference.documentID);
    document.updateData({
      'images': newImageList
    }).then((value) => print('Success')).catchError((error) => print('Error : $error'));
  }

  _addNewImagesToStorage(Map<String, Uint8List> newImagesMap) async
  {
    var storageReference = FirebaseStorage.instance.ref().child(widget.destination.city);
    for(var key in newImagesMap.keys)
    {
      var imageStorageReference = storageReference.child(key);
      StorageUploadTask storageUloadTask = imageStorageReference.putData(newImagesMap[key]);
      await storageUloadTask.onComplete.then((StorageTaskSnapshot value) => print('${value.error}')).catchError((error) => print('Error while uploading $error'));
    }
  }

   _addImages() async
  {
    print('Inside getImages');
    var imageList = await MultiImagePicker.pickImages(maxImages: 10, enableCamera: true);
    print('Before adding images lenght is ${widget.destination.photos.length}');
    Map<String, Uint8List> newImagesMap = Map<String, Uint8List>();
    List<dynamic> newImages = List<dynamic>();
    for(Asset imageFile in imageList)
    {
      
      newImages.add(imageFile.name);
      var byteData = await imageFile.getByteData(quality: 100);
      newImagesMap.putIfAbsent(imageFile.name, () => byteData.buffer.asUint8List());
      widget.destination.photos.add(new Photo(imgUrl: byteData.buffer.asUint8List()));
      
    }
    
    await _addNewImagesToStorage(newImagesMap);

    await _updateImagesList(newImages);

    widget.destination.wallpaperMap.clear();

    setState(() {
      print('After adding images lenght is ${widget.destination.photos.length}');
    });
  }

  Future _getImages() async{
    StorageReference photosReference = FirebaseStorage.instance.ref().child(widget.destination.city);
    for (var imageUrl in widget.destination.images) {
      Uint8List imageUint8List;
      if(imageUrl !=null)
      {
        int maxSize = 17*1024*1024;
        imageUint8List = await photosReference.child(imageUrl.toString()).getData(maxSize);
        Photo photo = new Photo(imgUrl: imageUint8List);
        widget.destination.photos.add(photo);
        widget.destination.mappedPhotos.putIfAbsent(imageUrl, () => photo);
      }
    }
    setState(() {
      
    });
    return widget.destination.photos;
  }

  @override
  void initState() {
    super.initState();
    
    tabController = new TabController(length: 2, vsync: this);
    tabBarItem = new TabBar(
      tabs: [
        new Tab(
          icon: new Icon(Icons.details),
        ),
        new Tab(
          icon: new Icon(Icons.grid_on),
        ),
      ],
      controller: tabController,
      indicatorColor: Colors.red,
    );
  }

  void open(BuildContext context, int index)
  {
    Navigator.push(context, 
    MaterialPageRoute(
        builder: (context) => GalleryPhotoViewWrapper(
          galleryItems: widget.destination.photos,
          backgroundDecoration: const BoxDecoration(
              color: Colors.black,
            ),
        initialIndex: index,
        scrollDirection: Axis.horizontal,
      )
    )
    );
  }

  @override
  Widget build(BuildContext context) {
    var detailsContainer = Container(
      width: double.infinity,
      height: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20.0),
      ),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Text(
          '${widget.destination.description}',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.0,
            fontWeight: FontWeight.bold
          ),
        ),
      ),
    );

    var gridView = new GridView.builder(
        itemCount: widget.destination.photos.length,
        gridDelegate:
            new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
        itemBuilder: (BuildContext context, int index) {
          Photo photo = widget.destination.photos[index];
          return new GestureDetector(
            child: Container(
                alignment: Alignment.center,
                child: Container(
                      margin: EdgeInsets.all(10.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: Colors.white
                      ),
                      child: PhotoView(
                        imageProvider: Image.memory(photo.imgUrl).image,
                        heroAttributes: PhotoViewHeroAttributes(tag: photo.imgUrl),
                        minScale: PhotoViewComputedScale.contained * 1,
                        maxScale: PhotoViewComputedScale.covered * 4,
                        initialScale: PhotoViewComputedScale.contained * 1,
                        backgroundDecoration: BoxDecoration(color: Theme.of(context).accentColor),
                      ),
                    ),
              ),
            onTap: () {
              tabController.index = 1;
              open(context, index);
            },
          );
        });

    return SafeArea(
      child: Scaffold(
        body: ListView(
          children: <Widget>[
            Stack(
              children: <Widget>[
                Container(
                height: 320,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30.0),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black26,
                      offset: Offset(0.0,2.0),
                      blurRadius: 6.0
                    )
                  ]
                ),
                child: Hero(
                  tag: widget.destination.wallpaperUrl,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: widget.destination.wallPaperImage == null ? Container(width: 100, height: 100, color: Colors.red,) :
                    Image(
                      image: Image.memory(widget.destination.wallPaperImage).image,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      IconButton(
                        color: Colors.black,
                        onPressed: () => Navigator.pop(context),
                        iconSize: 30.0,
                        icon: Icon(Icons.arrow_back),
                      ),
                      Text('${widget.destination.visitedDate.toDate().year}-${widget.destination.visitedDate.toDate().month}-${widget.destination.visitedDate.toDate().day}', style: TextStyle(color: Colors.black, fontSize: 15.0, fontWeight: FontWeight.bold),)
                    ],
                  ),
                ),
                Positioned(
                  bottom: 20.0,
                  left: 20.0,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text('${widget.destination.city}', style: TextStyle(fontSize: 35.0, fontWeight: FontWeight.bold, color: Colors.white70),),
                      Row(
                        children: <Widget>[
                          Icon(FontAwesomeIcons.locationArrow, color: Colors.white70 ,size: 15.0,),
                          SizedBox(width: 5.0),
                          Text(
                            widget.destination.country,
                            style: TextStyle(color: Colors.white70, fontSize: 20.0),
                          ),
                        ],
                      )
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 20.0,),
            tabBarItem,
            Container(
              height: 300,
              child: DefaultTabController(
                length: 2,
                child: TabBarView(
                  controller: tabController,
                  children: <Widget>[
                    detailsContainer,
                    widget.destination.mappedPhotos.length > 0 ?
                    gridView :
                    FutureBuilder(
                      future: _getImages(),
                      builder: (BuildContext context, AsyncSnapshot snapShot)
                      {
                        if(snapShot.hasData)
                        {
                          return gridView;
                        }
                        return Container(
                          child: CircularProgressIndicator(backgroundColor: Colors.white70,));
                      },
                    )
                  ],
                ),
              ),
            )
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addImages,
          child: Icon(Icons.add),
          backgroundColor: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}

class GalleryPhotoViewWrapper extends StatefulWidget {
  GalleryPhotoViewWrapper({
    this.loadingChild,
    this.backgroundDecoration,
    this.minScale,
    this.maxScale,
    this.initialIndex,
    @required this.galleryItems,
    this.scrollDirection = Axis.horizontal,
  }) : pageController = PageController(initialPage: initialIndex, viewportFraction: 1.0, keepPage: true);

  final Widget loadingChild;
  final Decoration backgroundDecoration;
  final dynamic minScale;
  final dynamic maxScale;
  final int initialIndex;
  final PageController pageController;
  final List<Photo> galleryItems;
  final Axis scrollDirection;

  @override
  State<StatefulWidget> createState() {
    return _GalleryPhotoViewWrapperState();
  }
}

class _GalleryPhotoViewWrapperState extends State<GalleryPhotoViewWrapper> {
  int currentIndex;

  @override
  void initState() {
    currentIndex = widget.initialIndex;
    super.initState();
  }

  void onPageChanged(int index) {
    setState(() {
      currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: widget.backgroundDecoration,
        constraints: BoxConstraints.expand(
          height: MediaQuery.of(context).size.height,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: <Widget>[
            PhotoViewGallery.builder(
              scrollPhysics: const BouncingScrollPhysics(),
              builder: (BuildContext context, int index)
              {
                Photo photo = widget.galleryItems[index];
                return PhotoViewGalleryPageOptions(
                      minScale: PhotoViewComputedScale.contained * 0.9,
                      maxScale: PhotoViewComputedScale.covered * 4,
                      imageProvider: Image.memory(photo.imgUrl,fit: BoxFit.fitWidth,).image,
                      initialScale: PhotoViewComputedScale.contained * 0.9,
                      basePosition: Alignment.center,
                      heroAttributes: PhotoViewHeroAttributes(tag:photo.imgUrl));
              },
              itemCount: widget.galleryItems.length,
              loadingBuilder: (BuildContext context, ImageChunkEvent imageChunckEvent){
                return widget.loadingChild;
              },
              backgroundDecoration: widget.backgroundDecoration,
              pageController: widget.pageController,
              onPageChanged: onPageChanged,
              scrollDirection: widget.scrollDirection,
            ),
          ],
        ),
      ),
    );
  }
}