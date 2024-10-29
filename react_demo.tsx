import ListItem from "@/comps/ListItem";
import TabBar from "@/comps/TabBar";
import { ChildContext } from "@/service/context";
import { useAuth } from "@/service/hook";
import request from "@/service/request";
import { Base64 } from "@/service/utils";
import { Arrow } from "@taroify/icons";
import { View } from "@tarojs/components";
import { navigateTo, useRouter } from "@tarojs/taro";
import React, { useContext, useEffect, useState } from "react";
import "./list.scss";

const cusStyle = {
  display: "flex",
  alignItems: "center",
  padding: "0 12px",
  width: "280px",
  height: "60px",
  position: "static" as any,
};

export default function App() {
  const childContext = useContext(ChildContext);
  const [list, setList] = useState<any>([]);
  const router = useRouter();
  const { getAuth } = useAuth();

  const checkPay = async (scaleTableCode) => {
    if (wx._unLogin) {
      navigateTo({
        url: `/pages/login/index?returnUrl=${"/pages/evaluate/list"}`,
      });
    } else {
      const res = await request({
        url: "/order/check",
        data: { scaleTableCode },
      });
      if (!res.data.hasPaidOrder) {
        navigateTo({
          url: `/orderPackage/pages/order/gmsPay?code=${scaleTableCode}`,
        });
      } else {
        if (childContext.child.len) {
          navigateTo({
            url: `/childPackage/pages/choose?code=${scaleTableCode}&orderId=${res.data.orderId}`,
          });
        } else {
          const returnUrl = Base64.encode(
            `/childPackage/pages/choose?code=${scaleTableCode}&orderId=${res.data.orderId}`
          );

          navigateTo({
            url: `/childPackage/pages/manage?code=${scaleTableCode}&returnUrl=${returnUrl}`,
          });
        }
      }
    }
  };

  const getList = async () => {
    const res = await request({
      url: "/scaleTable/list",
    });
    setList(res.data);
  };

  const getChild = async () => {
    const res = await request({
      url: "/children/list",
      data: { pageNo: 1, pageSize: 1000 },
    });
    childContext.updateChild({ len: res.data.children?.length });
  };

  useEffect(() => {
    if (router.params.channel || router.params.orgid || wx._orgId) {
      getAuth(getList, {
        channel: router.params.channel || "",
        orgid: router.params.orgid || wx._orgId,
      });
    } else {
      getList();
      getChild();
    }
  }, []);

  return (
    <div className="index">
      <View2 className="list-wrap">
        {list?.map((v, i) => (
          <div key={i} className="list" onClick={() => checkPay(v.code)}>
            <ListItem
              left={v.name}
              right={
                <span className="arrow-icon">
                  <Arrow color="#fff" />
                </span>
              }
              customStyles={cusStyle}
            />
          </div>
        ))}
      </View2>
      <TabBar current="index" />
    </div>
  );
}
