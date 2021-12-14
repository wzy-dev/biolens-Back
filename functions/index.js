/* eslint-disable max-len */

// Import logger to log
import {region} from "firebase-functions";

// The Firebase Admin SDK to access Firestore.
import admin from "firebase-admin";
admin.initializeApp();

const db = admin.firestore();

export const updateCategory = region("europe-west1").firestore.document("/categories/{documentId}")
    .onUpdate(async (change, context) => {
      const data = change.after.data();
      const products = await db.collection("products").where("ids.category", "==", context.params.documentId).get();

      return await Promise.all(
          products.docs.map((product) => {
            const docRef = db.collection("products").doc(product.id);
            docRef.update({
              "names.category": data.name,
            });
          }),
      );
    });

export const updateSubCategory = region("europe-west1").firestore.document("/categories/{categoryId}/subcategories/{subcategoryId}")
    .onUpdate(async (change, context) => {
      const data = change.after.data();
      const products = await db.collection("products").where("ids.subCategory", "==", context.params.subcategoryId).get();

      return await Promise.all(
          products.docs.map((product) => {
            const docRef = db.collection("products").doc(product.id);
            docRef.update({
              "names.subCategory": data.name,
            });
          }),
      );
    });

export const updateIndication = region("europe-west1").firestore.document("/indications/{indicationId}")
    .onUpdate(async (change, context) => {
      const data = change.after.data();
      const products = await db.collection("products").where("ids.indications", "array-contains", context.params.indicationId).get();

      return await Promise.all(
          products.docs.map((product) => {
            const dataDoc = product.data();
            const indicationIndex = dataDoc.ids.indications.findIndex((elm) => elm == context.params.indicationId);
            const names = dataDoc.names.indications;
            names[indicationIndex]=data.name;

            const docRef = db.collection("products").doc(product.id);
            docRef.update({
              "names.indications": names,
            });
          }),
      );
    });

export const updateTag = region("europe-west1").firestore.document("/tags/{tagId}")
    .onUpdate(async (change, context) => {
      const data = change.after.data();
      const products = await db.collection("products").where("ids.tags", "array-contains", context.params.tagId).get();

      return await Promise.all(
          products.docs.map((product) => {
            const dataDoc = product.data();
            const indicationIndex = dataDoc.ids.tags.findIndex((elm) => elm == context.params.tagId);
            const names = dataDoc.names.tags;
            names[indicationIndex]=data.name;

            const docRef = db.collection("products").doc(product.id);
            docRef.update({
              "names.tags": names,
            });
          }),
      );
    });
