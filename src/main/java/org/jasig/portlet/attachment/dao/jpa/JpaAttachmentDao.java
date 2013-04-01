/**
 * Licensed to Jasig under one or more contributor license
 * agreements. See the NOTICE file distributed with this work
 * for additional information regarding copyright ownership.
 * Jasig licenses this file to you under the Apache License,
 * Version 2.0 (the "License"); you may not use this file
 * except in compliance with the License. You may obtain a
 * copy of the License at:
 *
 * http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on
 * an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied. See the License for the
 * specific language governing permissions and limitations
 * under the License.
 */
package org.jasig.portlet.attachment.dao.jpa;

import java.util.HashMap;
import java.util.Map;
import javax.persistence.NoResultException;
import org.apache.commons.codec.binary.Base64;
import org.jasig.portlet.attachment.dao.IAttachmentDao;
import org.jasig.portlet.attachment.model.Attachment;
import org.springframework.stereotype.Repository;
import org.springframework.transaction.annotation.Transactional;

import javax.persistence.TypedQuery;
import java.util.List;


/**
 * @author Chris Waymire (chris@waymire.net)
 */
@Repository
public class JpaAttachmentDao extends BaseJpaDao implements IAttachmentDao {
    private final Base64 base64 = new Base64();

    public Attachment get(final long attachmentId) {
        final Attachment attachment = this.getEntityManager().find(Attachment.class, attachmentId);
        return attachment;
    }

    public Attachment get(final String guid) {
        final Map<String,String> params = new HashMap<String,String>() {{ put("guid",guid); }};
        final Attachment attachment = this.getResult(Queries.GET_ATTACHMENT_BY_GUID,params);
        return attachment;
    }

    public List<Attachment> find(final String creator) {
        final Map<String,String> params = new HashMap<String,String>() {{ put("creator",creator); }};
        final List<Attachment> list = this.getResultList(Queries.FIND_ATTACHMENTS_BY_CREATOR,params);
        return list;
    }

    public List<Attachment> find(final String creator,final String filename) {
        final Map<String,String> params = new HashMap<String,String>()
        {{ put("creator",creator); put("filename",filename); }};
        final List<Attachment> list = this.getResultList(Queries.FIND_ATTACHMENTS_BY_FILENAME,params);
        return list;
    }

    @Transactional
    public Attachment save(Attachment attachment) {
        return this.getEntityManager().merge(attachment);
    }

    @Transactional
    public void delete(Attachment attachment) {
        this.getEntityManager().remove(attachment);
    }

    @Transactional
    public void delete(final long attachmentId) {
        Attachment attachment = this.get(attachmentId);
        if(attachment != null)
        {
            this.delete(attachment);
        }
    }

    private Attachment getResult(String select,Map<String,String> params) {
        try {
            final TypedQuery<Attachment> query = createQuery(select,params);
            Attachment attachment = query.getSingleResult();
            return attachment;
        } catch(NoResultException noResultException) {
            return null;
        }
    }

    private List<Attachment> getResultList(String select,Map<String,String> params) {
        try {
            final TypedQuery<Attachment> query = createQuery(select,params);
            List<Attachment> results = query.getResultList();
            return results;
        } catch(NoResultException noResultException) {
            return null;
        }
    }

    private TypedQuery<Attachment> createQuery(String select,Map<String,String> params) {
        final TypedQuery<Attachment> query = this.getEntityManager().createNamedQuery(select,Attachment.class);
        for(String key : params.keySet()) {
            query.setParameter(key,params.get(key));
        }
        return query;
    }

}
