with Ada.Text_IO;        use Ada.Text_IO;
with Ada.Strings.Unbounded; use Ada.Strings.Unbounded;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;

procedure Askeriaracsistemi is

   type Vehicle_Type is (Hava, Kara, Deniz);
   type Operasyonel_Status is (Operasyonel, Arizali);

   type Vehicle is record
      Name         : Unbounded_String;
      VehicleType  : Vehicle_Type;
      Status       : Operasyonel_Status;
   end record;
   -- Araçları saklamak için dizi
   type Vehicle_List is array(1..100) of Vehicle;
   Vehicle_Count : Integer := 0;
   Vehicles : Vehicle_List;


   XML_File : constant String := "vehicles.xml";
   -- Araç bilgilerini XML eklemek
   procedure Add_Vehicle(Name : Unbounded_String; V_Type : Vehicle_Type; Status : Operasyonel_Status) is
      File : Ada.Text_IO.File_Type;
   begin
      if Vehicle_Count < 100 then

         Vehicle_Count := Vehicle_Count + 1;
         Vehicles(Vehicle_Count).Name := Name;
         Vehicles(Vehicle_Count).VehicleType := V_Type;
         Vehicles(Vehicle_Count).Status := Status;

         -- XML dosyasını açıyoruz
         if not Ada.Text_IO.Is_Open(File) then
            Ada.Text_IO.Create(File, Ada.Text_IO.Out_File, XML_File);
            Ada.Text_IO.Put_Line(File, "<?xml version=""1.0"" encoding=""UTF-8""?>");
            Ada.Text_IO.Put_Line(File, "<vehicles>");
         else
            Ada.Text_IO.Open(File, Ada.Text_IO.In_File, XML_File);
         end if;

         -- Araç bilgilerini XML'e yazıyoruz
         Ada.Text_IO.Put_Line(File, "  <vehicle>");
         Ada.Text_IO.Put_Line(File, "    <name>" & To_String(Name) & "</name>");
         case V_Type is
            when Hava => Ada.Text_IO.Put_Line(File, "    <type>Hava</type>");
            when Kara => Ada.Text_IO.Put_Line(File, "    <type>Kara</type>");
            when Deniz => Ada.Text_IO.Put_Line(File, "    <type>Deniz</type>");
         end case;
         case Status is
            when Operasyonel => Ada.Text_IO.Put_Line(File, "    <status>Operasyonel</status>");
            when Arizali => Ada.Text_IO.Put_Line(File, "    <status>Arizali</status>");
         end case;
         Ada.Text_IO.Put_Line(File, "  </vehicle>");
         Ada.Text_IO.Put_Line(File, "</vehicles>");
         Ada.Text_IO.Close(File);
      else
         Put_Line("Araç eklenemedi! Maksimum araç sayısına ulaşıldı.");
      end if;
   end Add_Vehicle;

   -- Araçları yazdırmak ve filtrelemek
   procedure Print_Vehicles(Filter_Type : Vehicle_Type := Hava; Filter_Status : Operasyonel_Status := Operasyonel) is
   begin
      if Vehicle_Count = 0 then
         Put_Line("Liste Boş ! Lütfen önce araç eklemesi yapınız.");
         return;
      end if;
      Put_Line("Askeri Araçlar:");
      for I in 1..Vehicle_Count loop
         if (Vehicles(I).VehicleType = Filter_Type or Filter_Type = Hava) and
            (Vehicles(I).Status = Filter_Status or Filter_Status = Operasyonel) then
            Put_Line("Araç Adı: " & To_String(Vehicles(I).Name));
            case Vehicles(I).VehicleType is
               when Hava => Put_Line("Tür: Hava");
               when Kara => Put_Line("Tür: Kara");
               when Deniz => Put_Line("Tür: Deniz");
            end case;
            case Vehicles(I).Status is
               when Operasyonel => Put_Line("Durum: Operasyonel");
               when Arizali => Put_Line("Durum: Arızalı");
            end case;
            Put_Line("----------------------------------------");
         end if;
      end loop;
   end Print_Vehicles;
-- Araç durumunu güncelleme
procedure Update_Vehicle_Status(Name : Unbounded_String; New_Status : Operasyonel_Status) is
   Found : Boolean := False;
begin
   for I in 1..Vehicle_Count loop
      if To_String(Vehicles(I).Name) = To_String(Name) then
         Vehicles(I).Status := New_Status;
         declare
            Status_Str : String := (case New_Status is
                                       when Operasyonel => "Operasyonel",
                                       when Arizali     => "Arızalı");
         begin
            Put_Line("Araç durumu güncellendi:");
            Put_Line("Araç Adı: " & To_String(Name) & " Yeni Durum: " & Status_Str);
         end;
         Found := True;
         exit;
      end if;
   end loop;

   if not Found then
      Put_Line("Hata: Belirtilen isimde bir araç bulunamadı.");
   end if;
end Update_Vehicle_Status;

   procedure UserInformations is
      Choice : Character;
      Name   : Unbounded_String;
      Temp_Name : String(1..100);
      Length : Integer;
      Type_Input : Integer;
      Status_Input : Integer;
      Filter_Type_Input : Character;
      Filter_Type : Vehicle_Type;
      Filter_Status : Operasyonel_Status;
   begin
      loop
         Put_Line("--Askeri Araç Sistemi--");
         Put_Line("1. Askeri Araç Ekle");
         Put_Line("2. Araçları Listele");
         Put_Line("3. Araçları Filtrele");
         Put_Line("4. Araç Güncelle");
         Put_Line("5. Çıkış");
         Put("Lütfen Seçim Yapınız (1 .. 5): ");
         Get(Choice);
         if Choice in '1' .. '5' then
            Choice := Choice;
         else
            Put_Line("Hata: Sadece 1-5 arası rakam girebilirsiniz.");
         end if;
         Skip_Line;

         case Choice is
            when '1' =>
               Put("Askeri Araç Adı Giriniz: ");
               Get_Line(Temp_Name, Length);

               if Length <= 100 then
                  Name := To_Unbounded_String(Temp_Name(1..Length));
               else
                  Put_Line("Girilen isim çok uzun! Lütfen 100 karakterden az girin.");
                  return;
               end if;

               -- Araç tipi alınır
               Put("Araç Tipi Giriniz (1: Hava, 2: Kara, 3: Deniz): ");
               Get(Type_Input);

               if Type_Input < 1 or Type_Input > 3 then
                  Put_Line("Geçersiz Araç Tipi! Lütfen 1, 2 veya 3 girin.");
                  return;
               end if;
               -- Araç durumu alınır
               Put("Araç Durumu Giriniz (1: Operasyonel, 2: Arızalı): ");
               Get(Status_Input);

               if Status_Input < 1 or Status_Input > 2 then
                  Put_Line("Geçersiz Durum! Lütfen 1 veya 2 girin.");
                  return;
               end if;

               -- Araç bilgilerini XML dosyasına ekle
               Add_Vehicle(Name, Vehicle_Type'Val(Type_Input - 1), Operasyonel_Status'Val(Status_Input - 1));

            when '2' =>
               -- Araçları listele
               Print_Vehicles;

            when '3' =>
               -- Araçları filtrele
               Put_Line("Askeri Araçları Filtrelemek İçin Seçim Yapın:");
               Put_Line("1. Hava Araçları  - Operasyonel");
               Put_Line("2. Hava Araçları  - Arızalı");
               Put_Line("3. Kara Araçları  - Operasyonel");
               Put_Line("4. Kara Araçları  - Arızalı");
               Put_Line("5. Deniz Araçları - Operasyonel");
               Put_Line("6. Deniz Araçları - Arızalı");
               Put_Line("0. Tüm Araçlar");

               Get(Filter_Type_Input);
               if Filter_Type_Input in '0' .. '6' then
                  Filter_Type_Input := Filter_Type_Input;
               else
                  Put_Line("Hata: Filtre için sadece 0-6 arası rakam girebilirsiniz.");
               end if;
               if Filter_Type_Input = '1' then
                  Filter_Type := Hava;
                  Filter_Status := Operasyonel;
               elsif Filter_Type_Input = '2' then
                  Filter_Type := Hava;
                  Filter_Status := Arizali;
               elsif Filter_Type_Input = '3' then
                  Filter_Type := Kara;
                  Filter_Status := Operasyonel;
               elsif Filter_Type_Input = '4' then
                  Filter_Type := Kara;
                  Filter_Status := Arizali;
               elsif Filter_Type_Input = '5' then
                  Filter_Type := Deniz;
                  Filter_Status := Operasyonel;
               elsif Filter_Type_Input = '6' then
                  Filter_Type := Deniz;
                  Filter_Status := Arizali;
               end if;

               -- Filtrelenmiş araçları yazdır
               if Filter_Type_Input /= '0' then
                  Print_Vehicles(Filter_Type, Filter_Status);
               elsif Filter_Type_Input = '0' then
                  Print_Vehicles;
                  end if;
               when '4' =>
               -- Araç güncelle
               Put_Line("Araç Durumunu Güncelleme:");
                if Vehicle_Count = 0 then
                  Put_Line("Liste Boş ! Lütfen önce araç eklemesi yapınız.");
               else
               Put("Araç Adını Girin: ");
               Get_Line(Temp_Name, Length);
               if Length <= 100 then
                  Name := To_Unbounded_String(Temp_Name(1..Length));
               else
                  Put_Line("Girilen isim çok uzun! Lütfen 100 karakterden az girin.");
                  return;
               end if;

               Put("Yeni Durumu Girin (1: Operasyonel, 2: Arızalı): ");
               Get(Status_Input);

               if Status_Input < 1 or Status_Input > 2 then
                  Put_Line("Geçersiz Durum! Lütfen 1 veya 2 girin.");
                  return;
               end if;

               Update_Vehicle_Status(Name, Operasyonel_Status'Val(Status_Input - 1));
               end if;
            when '5' =>
               -- Çıkış yap
               Put("Programdan çıkış yapılmıştır.");
               exit;
            when others =>
               Put_Line("Geçersiz giriş..");
         end case;
      end loop;
   end UserInformations;

begin
   UserInformations;
end Askeriaracsistemi;
