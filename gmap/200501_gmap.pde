import googlemapper.*;
GoogleMapper gMapper;
double mapCenterLat = 35.009529;    //新宿駅の緯度
double mapCenterLon = 135.749822;   //新宿駅の経度
int zoomLevel = 12;  // ズームレベル
String mapType = GoogleMapper.MAPTYPE_SATELLITE;  // 表示の種類

void setup() {
    size(900,600);
    gMapper  = new GoogleMapper(mapCenterLat, mapCenterLon, (int)zoomLevel, mapType, width, height);
    initLine();
    initStation();
    initRail();

    //日本語対応フォントを設定する
    PFont mono = createFont("Meiryo", 16);
    textFont(mono);

    Thread t1 = new Thread(new UpdateStationThread());
    t1.start();
}
ArrayList<Line> lines = new ArrayList<Line>();
void initLine() {
    BufferedReader reader = createReader("line20200306free.csv");
    String line;
    try {
        while (true) {
            line = reader.readLine();
            if (line == null) {
                break;
            }
            String[] words = line.split(",");
            try {
                int id = Integer.parseInt(words[0]);
                if (id < 10000) {    //idが4桁なのは新幹線なので
                    continue;        //読み飛ばす
                }
            }
            catch(NumberFormatException e) {    //数字じゃなければ読み飛ばす
                continue;
            }
            int status = Integer.parseInt(words[11]);
            if (status == 2) {  //statusが2なら廃止駅なので飛ばす
                continue;
            }
            int id = Integer.parseInt(words[0]);
            String name = words[2];
            double lon = Double.parseDouble(words[8]);
            double lat = Double.parseDouble(words[9]);
            int zoom = Integer.parseInt(words[10]);
            lines.add(new Line(id,name,lon,lat,zoom));
        }
    }
    catch(IOException e) {
        println("File reader error! at initLine()");
    }
}

ArrayList<Station>stations = new ArrayList<Station>();  //全ての駅データを保持
ArrayList<Station>stationsOnMap = new ArrayList<Station>(); //表示されている画面の周辺にある駅を保持
void initStation() {
    BufferedReader reader = createReader("station20200316free.csv");
    String line;
    noStroke();
    //stations.clear();
    //stationsOnMap.clear();

    try {
        while (true) {
            line = reader.readLine();
            if (line == null) {
                break;
            }
            String[] words = line.split(",");
            try {
                int id = Integer.parseInt(words[0]);
                if (id < 10000) {
                    continue;
                }
            }
            catch(NumberFormatException e) {
                continue;
            }
            int status = Integer.parseInt(words[13]);
            if (status == 2) {  //statusが2なら
                continue;  //廃止駅なので飛ばす
            }
            int id = Integer.parseInt(words[0]);
            String name  = words[2];
            int lineId = Integer.parseInt(words[5]);
            double lon   = Double.parseDouble(words[9]);
            double lat   = Double.parseDouble(words[10]);
            double x     = gMapper.lon2x(lon);
            double y     = gMapper.lat2y(lat);
            Station station = new Station(id, name,lineId,lon,lat, (float)x, (float)y);
            stations.add(station);
            if(x >= 0 - width  && x <= width*2 && y >= 0 -height && y <= height*2){
             stationsOnMap.add(station);
            }
        }
    }
    catch(IOException e) {
        println("File reader error! at drawStation");
    }
}

void initRail(){
    BufferedReader reader = createReader("join20200306.csv");
    String line;
    try{
        while(true){
            line = reader.readLine();
            if(line == null){
                break;
            }
            String[] words = line.split(",");
            try{
                int start = Integer.parseInt(words[1]);
                int end = Integer.parseInt(words[2]);
                Station startStation = getStation(start);
                Station endStation = getStation(end);
                if(startStation == null || endStation == null){
                    continue;
                }
                startStation.nextStation = endStation;
                endStation.prevStation = startStation;
            }catch(NumberFormatException e){
                continue;
            }

        }
    }catch(IOException e){
        println("File reader error! at drawRail");
    }
}

float mapX = 0;
float mapY = 0;
void draw() {
    background(0);
    resetMatrix();
    translate(mapX, mapY);
    drawStation();
    drawRail();
    drawName();               //駅の名前をかく
}
synchronized void drawStation(){
  for(int i = 0; i < stationsOnMap.size(); i++){
    stationsOnMap.get(i).draw();
  }
  for(Station station : stationsOnMap){
    station.drawName();
  }
}

synchronized void drawRail(){
  for(int i = 0; i < stationsOnMap.size(); i++){
    Station startStation = stationsOnMap.get(i);
    Station endStation = startStation.nextStation;

    if(endStation != null){
        strokeWeight(2);  //線を細く
        stroke(startStation.myColor);  //自分の路線の色に
        line((int)startStation.x, (int)startStation.y, (int)endStation.x, (int)endStation.y);
    }
  }
}

void drawName(){
  int addY = 0;
  for(int i = 0; i < stationsOnMap.size(); i++){
    Station station = stationsOnMap.get(i);
    if(station.isOnStation()){
      fill(255);
      text(station.name + "("+station.line.name+")",(int)station.x,(int)station.y+addY);
      addY += 15;
    }
  }
}

void mouseDragged(){
    mapX += mouseX - pmouseX;
    mapY += mouseY - pmouseY;
}
void keyPressed ()  {
    if(keyCode == UP){
        zoomLevel++;
        renew();
    }
    if(keyCode == DOWN){
        zoomLevel--;
        renew();
    }
}
void renew(){
    double lon = gMapper.x2lon(mapX+width/2);  //mapX更新のために現在のスケッチの中心座標の経度を求める
    double lat = gMapper.y2lat(mapY+height/2); //mapY更新のために現在のスケッチの中心座標の緯度を求める
    gMapper = new GoogleMapper(mapCenterLat, mapCenterLon, (int)zoomLevel, mapType, width, height);
    updateStation();
    mapX = (float)(gMapper.lon2x(lon)-width/2);  //mapXの更新(中心をそろえるため);
    mapY = (float)(gMapper.lat2y(lat)-height/2);  //mapYの更新(中心をそろえるため);
}
void updateStation(){
    noStroke();
    //  stationsOnMap.clear();
    ArrayList<Station> newStationsOnMap = new ArrayList<Station>();

    for(Station station : stations){
        float x = (float)gMapper.lon2x(station.lon);
        float y = (float)gMapper.lat2y(station.lat);
        station.x = x;
        station.y = y;
        if(x >= 0 - width *2 && x <= width*2 && y >= 0 -height *2&& y <= height*2){
            newStationsOnMap.add(station);
        }
    }
    stationsOnMap = newStationsOnMap;    //更新！
}


class Line {

    int id;
    String name;      //路線名
    double lon, lat;  //路線の中央緯度と中央経度
    int zoom;        //路線全体を表示するのに適したズーム量
    color myColor;
    Station startingStation;  //始発駅

    Line(int id, String name, double lon, double lat, int zoom){
        this.id = id;
        this.name = name;
        this.lon = lon;
        this.lat = lat;
        this.zoom = zoom;
        myColor = color((int)random(255), (int)random(255), (int)random(255));
    }
}
Line getLine(int id){
    for(Line line: lines){
        if(line.id == id){
            return line;
        }
    }
    return null;
}

int r = 10;
boolean showName = false;   //駅名を全て表示したい場合はtrueに
class Station {

  String name;
  double lon, lat;  //経度、緯度
  float x, y;
  int id;        //駅自体のid
  int lineId;    //この駅が所属する路線のid

  Station nextStation;  //次の駅
  Station prevStation;  //前の駅
  Line line;    //所属路線
  color myColor;

  Station(int id, String name, int lineId, double lon, double lat, float x, float y){
    this.name = name;
    this.lon = lon;
    this.lat = lat;
    this.x = x;
    this.y = y;
    this.id = id;
    this.lineId = lineId;
    line = getLine(lineId);
    try{
        myColor = line.myColor;
        if(line.startingStation == null){
            line.startingStation = this;
        }
    }catch(NullPointerException e){
        myColor = color(0,0,0);
    }
  }

  void draw(){
    noStroke();
    fill(myColor, 100);
    ellipse((int)x,(int)y,r,r);
  }

  void drawName(){
    if(showName){
      fill(myColor);
      text(name,(int)x,(int)y);
    }
  }

  void drawPathName(){
    fill(255,0,0);
    text(name,(int)x,(int)y);
  }

  boolean isOnStation(){
    if(abs(mouseX - (x+mapX)) <= r/2 && abs(mouseY - (y+mapY)) <= r/2){
      return true;
    }
    return false;
  }
}
//idで駅を検索  見つからなかった場合はnullを返す
Station getStation(int id){  //idはユニーク
  for(Station station : stations){  //全駅探して
    if(station.id == id){  //idが等しければ
      return station;  //その駅を返す
    }
  }
  return null;
}

//現在のスケッチ上とその周辺にある駅の情報を探す
class UpdateStationThread extends Thread {
    public synchronized void run(){
        while(true){

            ArrayList<Station> newStationsOnMap = new ArrayList<Station>();
            for(Station station : stations){
                float x =  station.x;
                float y =  station.y;
                if(x >= 0 - width *2 - mapX && x <= width*2 - mapX && y >= 0 -height *2 - mapY && y <= height* 2 - mapY){  //現在のスケッチより2枚分周りにある駅かどうか
                    newStationsOnMap.add(station);
                }
            }
            stationsOnMap = newStationsOnMap;    //更新！
            try{
                this.sleep(1000);    //1秒間に1回呼ぶやで
            }catch(Exception e){
                println("Error at updateStation()");
            }
        }
    }
}
