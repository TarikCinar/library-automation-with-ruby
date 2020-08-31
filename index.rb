require 'sinatra'
require 'date'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'time'

enable :sessions
set :session_secret, 'secret'
set :views, File.dirname(__FILE__) + '/views'

set :public_folder => "static"
set :root ,File.dirname(__FILE__)
set :sessions, :domain => 'foo.com'


@db = SQLite3::Database.open 'user.db'
@db.execute "CREATE TABLE IF NOT EXISTS user(id INTEGER PRIMARY KEY AUTOINCREMENT,admin INTEGER,isim TEXT,soyisim TEXT,email TEXT,password TEXT,resim TEXT)"
@db.execute "CREATE TABLE IF NOT EXISTS book(id INTEGER PRIMARY KEY AUTOINCREMENT,resim TEXT,isim TEXT,yazar TEXT,kategori Text,basim_yili TEXT,basim_dili TEXT,okuma_sayisi INTEGER,slug TEXT,adet INTEGER,sayfa_sayisi INTEGER)"
@db.execute "CREATE TABLE IF NOT EXISTS Ebook(id INTEGER PRIMARY KEY AUTOINCREMENT,resim TEXT,isim TEXT,yazar TEXT,kategori Text,basim_yili TEXT,basim_dili TEXT,okuma_sayisi INTEGER,slug TEXT,sayfa_sayisi INTEGER)"
@db.execute "CREATE TABLE IF NOT EXISTS dergi(id INTEGER PRIMARY KEY AUTOINCREMENT,resim TEXT,isim TEXT,kategori Text,basim_yili TEXT,basim_dili TEXT,okuma_sayisi INTEGER,slug TEXT,adet INTEGER,sayfa_sayisi INTEGER)"
@db.execute "CREATE TABLE IF NOT EXISTS alinan_kitaplar(id INTEGER PRIMARY KEY AUTOINCREMENT,kitap_id INTEGER,alan_kisi INTEGER,alma_tarihi TEXT,verilecek_tarih TEXT,teslim_tarihi TEXT,teslim_edildimi INTEGER)"
@db.execute "CREATE TABLE IF NOT EXISTS alinan_dergiler(id INTEGER PRIMARY KEY AUTOINCREMENT,dergi_id INTEGER,alan_kisi INTEGER,alma_tarihi TEXT,verilecek_tarih TEXT,teslim_tarihi TEXT,teslim_edildimi INTEGER)"

$hata=""
$success=""
$referer=""
$login=""

#
#
#
#
# GET REQUESTS
#
#
#

get '/' do
  @db = SQLite3::Database.open 'user.db'
  @query = @db.execute "SELECT * FROM book "
  @e_kitap = @db.execute "SELECT * FROM Ebook "
  @dergi = @db.execute "SELECT * FROM dergi WHERE basim_yili BETWEEN datetime('now', '-100 days') AND datetime('now', 'localtime');"
  @yeni_kitaplar=@db.execute "SELECT * FROM book WHERE basim_yili BETWEEN datetime('now', '-30 days') AND datetime('now', 'localtime');"
  @cok_okunanlar=@db.execute "SELECT * FROM (SELECT * FROM book ORDER BY okuma_sayisi DESC LIMIT 10) ORDER BY okuma_sayisi ASC;"

  @hata=$hata
  @success=$success
    if get_id !=-1
    @giris_yapilmismi=true
  else
    @giris_yapilmismi=false
  end
  $success=""
  $hata=""
  erb :index
end



get '/admin/tum-degiler' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    @book_all = @db.execute "SELECT * FROM dergi"
    erb :admin_tum_dergiler
  end
end

get '/admin/dergi-ekle' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    @user_all = @db.execute "SELECT * FROM user"
    erb :admin_dergi_ekle
  end
end

get '/admin/tum-kitaplar' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    @book_all = @db.execute "SELECT * FROM book"
    erb :admin_tum_kitaplar
  end
  end

get '/admin/kitap-ekle' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    @user_all = @db.execute "SELECT * FROM user"
    erb :admin_kitap_ekle
  end
end

get '/admin/kullanici-ekle' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    @user_all = @db.execute "SELECT * FROM user"
    erb :kullanici_ekle
  end
end
get '/admin/user' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    @user_all = @db.execute "SELECT * FROM user"
    erb :admin_user
  end
end

get '/admin' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    redirect '/admin/user'
  end
end

get '/edit' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  erb :profil_duzenle
end

get '/logout' do
  $login=""
  redirect '/'
end

get '/kitaplar' do
  @db = SQLite3::Database.open 'user.db'
  @kitaplar = @db.execute "SELECT * FROM book"
  if get_id !=-1
    @giris_yapilmismi=true
  else
    @giris_yapilmismi=false
  end
  erb :kitaplar
end

get '/dergiler' do
  @hata=$hata
  @success=$success
  $hata=""
  $success=""
  @db = SQLite3::Database.open 'user.db'
  @dergiler = @db.execute "SELECT * FROM dergi"
  if get_id !=-1
    @giris_yapilmismi=true
  else
    @giris_yapilmismi=false
  end
  erb :dergiler
end


get '/iletisim' do
  if get_id !=-1
    @giris_yapilmismi=true
  else
    @giris_yapilmismi=false
  end
  erb :iletisim
end

get '/bize-sorun' do
  if get_id !=-1
    @giris_yapilmismi=true
  else
    @giris_yapilmismi=false
  end
  erb :bize_sorun
end

get '/kayit' do
  @msg=""
  if get_id !=-1
    $hata="  Yeni kayıt için çıkış yapmalısınız."
    redirect '/'
  end
  erb :kayit
end

get '/login' do
  @msg=""
  if get_id !=-1
    $hata="  Zaten giriş yaptınız."
    redirect '/'
  end
  erb :login
end

get '/profil' do
  if get_id !=-1
    @giris_yapilmismi=true
  else
    @giris_yapilmismi=false
    redirect '/'
  end
  user_id=get_id
  @veritabani = SQLite3::Database.open 'user.db'
  @user = @veritabani.execute "SELECT * FROM user WHERE id='#{user_id}'"
  kitaplar = @veritabani.execute "SELECT * FROM alinan_kitaplar WHERE alan_kisi='#{user_id}' and teslim_edildimi='0'"
  dergiler = @veritabani.execute "SELECT * FROM alinan_dergiler WHERE alan_kisi='#{user_id}' and teslim_edildimi='0'"

  @resim_varmi= File.file?("static/profil_photo/#{@user[0][6]}")
  @user_ad="#{@user[0][2]} #{@user[0][3]}"

  @bilgiler_list=[]

  kitaplar.each { |i|
    kitap = @db.execute "SELECT * FROM book WHERE id='#{i[1]}'"
    temp=[kitap[0][1],kitap[0][2],i[3],i[4],kitap[0][8],kitap[0][0]]
    @bilgiler_list.push temp
  }

  @dergi_list=[]

  dergiler.each { |i|
    dergi = @db.execute "SELECT * FROM dergi WHERE id='#{i[1]}'"
    temp=[dergi[0][1],dergi[0][2],i[3],i[4],dergi[0][8],dergi[0][0]]
    @dergi_list.push temp
  }
  erb :profil
end

get '/kitap-icerigi/:slug' do
  slug=params[:slug]
  @db = SQLite3::Database.open 'user.db'
  @query = @db.execute "SELECT * FROM book WHERE slug='#{slug}'"
  erb :kitap_icerigi
end

get '/dergi-icerigi/:slug' do
  slug=params[:slug]
  @db = SQLite3::Database.open 'user.db'
  @query = @db.execute "SELECT * FROM dergi WHERE slug='#{slug}'"
  erb :dergi_icerigi
end

get '/kitap/category/:category' do
  @db = SQLite3::Database.open 'user.db'
  if get_id !=-1
    @giris_yapilmismi=true
  else
    @giris_yapilmismi=false
  end
  if params[:category]=="egitim"
    @kitaplar = @db.execute "SELECT * FROM book WHERE kategori='Eğitim'"
  elsif params[:category]=="edebiyat"
    @kitaplar = @db.execute "SELECT * FROM book WHERE kategori='Edebiyat'"
  elsif params[:category]=="cocuk"
    @kitaplar = @db.execute "SELECT * FROM book WHERE kategori='Cocuk&Genclik'"
  elsif params[:category]=="tarih"
    @kitaplar = @db.execute "SELECT * FROM book WHERE kategori='Tarih'"
  elsif params[:category]=="biyografi"
    @kitaplar = @db.execute "SELECT * FROM book WHERE kategori='Biyografi'"
  end
  erb :kitaplar_kategori
end

get '/dergi/category/:category' do
  @db = SQLite3::Database.open 'user.db'
  if get_id !=-1
    @giris_yapilmismi=true
  else
    @giris_yapilmismi=false
  end
  if params[:category]=="bilim"
    @dergiler = @db.execute "SELECT * FROM dergi WHERE kategori='Bilim'"
  elsif params[:category]=="uzay"
    @dergiler = @db.execute "SELECT * FROM dergi WHERE kategori='Uzay'"
  elsif params[:category]=="magazin"
    @dergiler = @db.execute "SELECT * FROM dergi WHERE kategori='Magazin'"
  elsif params[:category]=="tarih"
    @dergiler = @db.execute "SELECT * FROM dergi WHERE kategori='Tarih'"
  elsif params[:category]=="bilmece"
    @dergiler = @db.execute "SELECT * FROM dergi WHERE kategori='Bilmece'"
  elsif params[:category]=="cografya"
    @dergiler = @db.execute "SELECT * FROM dergi WHERE kategori='Coğrafya'"
  end
  erb :dergiler_kategori
end

get '/admin/tum-e-kitaplar' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    @book_all = @db.execute "SELECT * FROM Ebook"
    erb :admin_tum_e_kitaplar
  end

  end

get '/admin/e-kitap-ekle' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    @book_all = @db.execute "SELECT * FROM dergi"
    erb :admin_e_kitap_ekle
  end

end


get '/e-kitaplar' do
  @db = SQLite3::Database.open 'user.db'
  if get_id !=-1
    @giris_yapilmismi=true
  else
    @giris_yapilmismi=false
  end
  @book_all = @db.execute "SELECT * FROM Ebook"
  erb :e_kitaplar
end

get '/e-kitap-icerigi/:slug' do
  slug=params[:slug]
  @db = SQLite3::Database.open 'user.db'
  @query = @db.execute "SELECT * FROM Ebook WHERE slug='#{slug}'"
  @kitap="/document/#{@query[0][0]}.pdf"
  erb :e_kitap_icerek
end

get '/admin/alinan-kitaplar' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    @alinan_kitaplar=@db.execute "SELECT * FROM alinan_kitaplar"
    @kitap_list=[]
    @alinan_kitaplar.each {|i|
      kitap=@db.execute "SELECT * FROM book WHERE id='#{i[1]}'"
      user=@db.execute "SELECT * FROM user WHERE id='#{i[2]}'"
      @kitap_list.push [kitap[0][1],kitap[0][2],kitap[0][4],kitap[0][7],user[0][2],user[0][3],i[4],i[6]]
    }
    erb :admin_alinan_kitaplar
  end
  end

get '/admin/alinan-dergiler' do
  @db = SQLite3::Database.open 'user.db'
  @user = @db.execute "SELECT * FROM user WHERE id='#{get_id}'"
  if get_id==-1
    $referer="/admin"
    redirect '/login'
  elsif @user[0][1]
    @alinan_dergiler=@db.execute "SELECT * FROM alinan_dergiler"
    @dergi_list=[]
    @alinan_dergiler.each {|i|
      dergi=@db.execute "SELECT * FROM dergi WHERE id='#{i[1]}'"
      user=@db.execute "SELECT * FROM user WHERE id='#{i[2]}'"
      @dergi_list.push [dergi[0][1],dergi[0][2],dergi[0][3],dergi[0][6],user[0][2],user[0][3],i[4],i[6]]
    }
    erb :admin_alinan_dergiler
  end
end
#
#
#
#



#
#
# POST REQUESTS
#
#
#
#
#



post '/admin/dergi-ekle' do
  kitap_isim=params["isim"]
  kategori=params["kategori"]
  yil=params["yil"]
  dil=params["dil"]
  adet=params["adet"]
  @filename = params[:file][:filename]
  file = params[:file][:tempfile]
  name= @filename.split(//)
  isim=""
  for i in name
    if i=="."
      break
    end
    isim+=i
  end
  dosya_adi=@filename.gsub(isim,kitap_isim)
  resim_ismi=sluggify(dosya_adi)
  File.open("static/dergi_image/#{resim_ismi}", 'wb') do |f|
    f.write(file.read)
  end
  slug= sluggify(kitap_isim)
  @db = SQLite3::Database.open 'user.db'
  @db.execute "INSERT INTO dergi (resim , isim  , kategori , basim_yili , basim_dili,okuma_sayisi,slug,adet ) VALUES ('#{resim_ismi}','#{kitap_isim}','#{kategori}','#{yil}','#{dil}','#{0}','#{slug}','#{adet}')"
  redirect '/admin/dergi-ekle'
end
  post '/admin/kitap-ekle' do
    kitap_isim=params["isim"]
    yazar=params["yazar"]
    kategori=params["kategori"]
    yil=params["yil"]
    dil=params["dil"]
    adet=params["adet"]
    sayfa_say=params["sayfa"]
    @filename = params[:file][:filename]
    file = params[:file][:tempfile]
    name= @filename.split(//)
    isim=""
    for i in name
      if i=="."
        break
      end
      isim+=i
    end
    dosya_adi=@filename.gsub(isim,kitap_isim)
    resim_ismi=sluggify(dosya_adi)
    File.open("static/images/#{resim_ismi}", 'wb') do |f|
      f.write(file.read)
    end

  slug= sluggify(kitap_isim)
  @db = SQLite3::Database.open 'user.db'
  @db.execute "INSERT INTO book (resim , isim , yazar , kategori , basim_yili , basim_dili,okuma_sayisi,slug,adet,sayfa_sayisi ) VALUES ('#{resim_ismi}','#{kitap_isim}','#{yazar}','#{kategori}','#{yil}','#{dil}','#{0}','#{slug}','#{adet}','#{sayfa_say}')"
  redirect '/admin/kitap-ekle'
  end


post '/admin/e-kitap-ekle' do
    kitap_isim=params["isim"]
    yazar=params["yazar"]
    kategori=params["kategori"]
    yil=params["yil"]
    dil=params["dil"]
    sayfa_say=params["sayfa"]
    @filename = params[:file][:filename]
    file = params[:file][:tempfile]
    name= @filename.split(//)
    isim=""
    for i in name
      if i=="."
        break
      end
      isim+=i
    end
    dosya_adi=@filename.gsub(isim,kitap_isim)
    resim_ismi=sluggify(dosya_adi)
    File.open("static/e_kitap_image/#{resim_ismi}", 'wb') do |f|
      f.write(file.read)
    end

  slug= sluggify(kitap_isim)
  @db = SQLite3::Database.open 'user.db'
  @db.execute "INSERT INTO Ebook (resim , isim , yazar , kategori , basim_yili , basim_dili,okuma_sayisi,slug,sayfa_sayisi ) VALUES ('#{resim_ismi}','#{kitap_isim}','#{yazar}','#{kategori}','#{yil}','#{dil}','#{0}','#{slug}','#{sayfa_say}')"
  redirect '/admin/e-kitap-ekle'
end

post '/admin/user/edit' do
  admin_durum=0
  id=params['id']
  isim=params["isim"]
  soyisim=params["soyisim"]
  email=params["email"]
  password=params["password"]
  admin=params["admin"]
  if admin=="true"
    admin_durum=1
  end
  @db = SQLite3::Database.open 'user.db'
  @db.execute "UPDATE user SET isim='#{isim}' , soyisim='#{soyisim}' , email='#{email}',password='#{password}',admin='#{admin_durum}' WHERE id='#{id}'"
  redirect '/admin/user'
end

post '/admin/user/user-remove' do
  @db = SQLite3::Database.open 'user.db'
  @db.execute "DELETE FROM user WHERE id='#{params['id']}'"
  redirect '/admin/user'
end

post '/admin/kullanici-ekle' do
  isim=params['isim']
  soyisim=params['soyisim']
  email=params['email']
  password=params['password']
  admin=params['admin']

  if admin=="on"
    admin_durum=1
  else
    admin_durum=0
  end
  @db = SQLite3::Database.open 'user.db'
  @db.execute "INSERT INTO user (admin , isim , soyisim , email , password , resim ) VALUES ('#{admin_durum}','#{isim}','#{soyisim}','#{email}','#{password}','#{'-.jpg'}')"

  redirect 'admin/user'
end

post '/kitap-al' do
  id=params["id"]
  alan_id=get_id
  if get_id==-1
    $hata="Kitabı almak için önce giriş yapmalısın."
    redirect '/'
  else
    @db = SQLite3::Database.open 'user.db'
    query = @db.execute "SELECT * FROM alinan_kitaplar WHERE kitap_id=\"#{id}\" and alan_kisi='#{alan_id}' and teslim_edildimi='0'"
    if query.length >0
      $hata="  Kitap zaten alınmış"
      redirect '/'
    else
      time = DateTime.now
      alma_tarihi= time.strftime("%Y-%m-%d %H:%M:%S")
      future=DateTime.now+7
      verilecek_tarih= future.strftime("%Y-%m-%d")
      @db.execute "INSERT INTO alinan_kitaplar (kitap_id , alan_kisi , alma_tarihi , verilecek_tarih,teslim_tarihi,teslim_edildimi ) VALUES ('#{id}','#{alan_id}','#{alma_tarihi}','#{verilecek_tarih}','#{""}','#{0}')"
      okuma_sayisi=@db.execute "SELECT * FROM book WHERE id='#{id}'"
      @db.execute "UPDATE book SET okuma_sayisi='#{okuma_sayisi[0][7]+1}' WHERE id='#{id}'"
      $hata=""
      $success="Kitap alındı."
      redirect '/'
    end
  end
end

post '/dergi-al' do
  id=params["id"]
  alan_id=get_id
  if get_id==-1
    $hata="Dergiyi almak için önce giriş yapmalısın."
    redirect '/dergiler'
  else
    @db = SQLite3::Database.open 'user.db'
    query = @db.execute "SELECT * FROM alinan_dergiler WHERE dergi_id=\"#{id}\" and alan_kisi='#{alan_id}' and teslim_edildimi='0'"
    if query.length >0
      $hata="  Dergi zaten alınmış"
      redirect '/dergiler'
    else
      time = DateTime.now
      alma_tarihi= time.strftime("%Y-%m-%d %H:%M:%S")
      future=DateTime.now+7
      verilecek_tarih= future.strftime("%Y-%m-%d")
      @db.execute "INSERT INTO alinan_dergiler (dergi_id , alan_kisi , alma_tarihi , verilecek_tarih ) VALUES ('#{id}','#{alan_id}','#{alma_tarihi}','#{verilecek_tarih}')"
      okuma_sayisi=@db.execute "SELECT * FROM dergi WHERE id='#{id}'"
      @db.execute "UPDATE dergi SET okuma_sayisi='#{okuma_sayisi[0][6]+1}' WHERE id='#{id}'"
      $hata=""
      $success="Dergi alındı."
      redirect '/dergiler'
    end
  end
end


post '/edit' do
  @filename = params[:file][:filename]
  kullanici_name=params["isim"]
  soyisim=params["soyisim"]
  email=params["email"]
  sifre=params["sifre"]
  file = params[:file][:tempfile]
  name= @filename.split(//)
  isim=""
  for i in name
    if i=="."
      break
    end
    isim+=i
  end
  dosya_adi=@filename.gsub(isim,get_id.to_s)
  File.open("static/profil_photo/#{dosya_adi}", 'wb') do |f|
    f.write(file.read)
  end
  @db = SQLite3::Database.open 'user.db'
  @db.execute "UPDATE user SET resim='#{dosya_adi}', isim='#{kullanici_name}' , soyisim='#{soyisim}' , email='#{email}', password='#{sifre}' WHERE id='#{get_id}'"
  redirect '/profil'
end


post '/login' do
  email=params['email']
  password=params['password']
  @db = SQLite3::Database.open 'user.db'
  query = @db.execute "SELECT * FROM user WHERE email='#{email}' and password='#{password}'"
  if query.length==0
    @msg="Kullanıcı adı veya parola yanlış "
    erb :login
  else
    $login =email
    if $referer=='/admin'
      redirect '/admin'
      $referer=''
    else
      redirect '/'
    end
  end
end

post '/kayit' do
  isim=params['isim']
  soyisim=params['soyisim']
  email=params['email']
  password=params['password']
  password_again=params['password_again']

  @db = SQLite3::Database.open 'user.db'
  query = @db.execute "SELECT * FROM user WHERE email=\"#{email}\""
  if not password == password_again
    @msg="Şifreler eşleşmiyor"
    erb :kayit
  elsif query.length >0
    @msg="Bu email zaten kullanımda."
    erb :kayit
  else
    @db.execute "INSERT INTO user (admin , isim , soyisim , email , password , resim ) VALUES ('#{1}','#{isim}','#{soyisim}','#{email}','#{password}','#{'-.jpg'}')"
    $login =email
    redirect "/"
  end
end


post '/kitap-teslim' do
  user=get_id
  kitap_id=params['id']

  time = DateTime.now
  now= time.strftime("%Y-%m-%d %H:%M:%S")

  @db = SQLite3::Database.open 'user.db'
  @db.execute "UPDATE alinan_kitaplar SET teslim_tarihi='#{now}',teslim_edildimi='#{1}' WHERE kitap_id='#{kitap_id}' and alan_kisi='#{user}'"

  redirect '/profil'
end

post '/dergi-teslim' do
  user=get_id
  kitap_id=params['id']

  time = DateTime.now
  now= time.strftime("%Y-%m-%d %H:%M:%S")

  @db = SQLite3::Database.open 'user.db'
  @db.execute "UPDATE alinan_dergiler SET teslim_tarihi='#{now}',teslim_edildimi='#{1}' WHERE dergi_id='#{kitap_id}' and alan_kisi='#{user}'"

  redirect '/profil'
end

#
#
#
#
#
#


#
#
#
#
# METHODS
#
#



def sluggify(title)
  accents = {['á','à','â','ä','ã'] => 'a'} # Shortened
  accents.each do |ac,rep|
    ac.each do |s|
      title = title.gsub(s, rep)
    end
  end
  title = title.gsub("ı","i")
  title = title.gsub("ş","s")
  title = title.gsub("ç","c")
  title = title.gsub(/[^a-zA-Z0-9 ]/,"")
  title = title.gsub(/[ ]+/," ")
  title = title.gsub(/ /,"-")
  title = title.downcase
  title
end

def get_id
  user=$login
  if user.length > 0
    @db = SQLite3::Database.open 'user.db'
    query = @db.execute "SELECT * FROM user WHERE email=\"#{user}\""
    if query.length >0
      id=query[0][0]
    else
      id=-1
    end
  else
    id=-1
  end
  id
end
